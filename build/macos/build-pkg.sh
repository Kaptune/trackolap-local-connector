#!/usr/bin/env bash
#
# build/macos/build-pkg.sh - produce tlp-connector-<version>-<arch>.pkg
#
# MUST run on macOS: pkgbuild, productbuild, codesign and notarytool are Apple tools with
# no supported cross-platform equivalent. This is the one packaging step that cannot come
# out of the Linux cross-compile job; the release workflow runs it on a macos runner and
# everything else on ubuntu.
#
# Signing and notarisation are GUARDED, never silently skipped:
#   * no Developer ID identity  -> unsigned .pkg + a loud warning (usable for local testing
#                                  only; macOS 10.15+ REFUSES an un-notarised installer)
#   * no notarytool credentials -> signed but un-notarised + a loud warning
#
# Environment:
#   MACOS_INSTALLER_IDENTITY   "Developer ID Installer: TrackOlap (TEAMID)"
#   MACOS_APP_IDENTITY         "Developer ID Application: TrackOlap (TEAMID)"  (signs the binary)
#   NOTARY_PROFILE             a notarytool keychain profile name, OR
#   NOTARY_APPLE_ID + NOTARY_TEAM_ID + NOTARY_PASSWORD   (app-specific password)
#
# Usage:
#   build/macos/build-pkg.sh -v 1.4.2 -a arm64
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HERE="${ROOT}/build/macos"
OUT="${ROOT}/dist"

VERSION=""
ARCH="arm64"
BINARY=""
IDENTIFIER="com.trackolap.connector.pkg"

usage() {
  cat >&2 <<'EOF'
usage: build-pkg.sh -v VERSION [-a arm64|amd64] [-b PATH_TO_BINARY] [-o OUTDIR]
EOF
  exit "${1:-2}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--version) VERSION="$2"; shift 2 ;;
    -a|--arch)    ARCH="$2"; shift 2 ;;
    -b|--binary)  BINARY="$2"; shift 2 ;;
    -o|--out)     OUT="$2"; shift 2 ;;
    -h|--help)    usage 0 ;;
    *) echo "build-pkg.sh: unknown option $1" >&2; usage ;;
  esac
done

[[ -n "$VERSION" ]] || { echo "build-pkg.sh: -v VERSION is required" >&2; usage; }
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "build-pkg.sh: macOS only (pkgbuild/productbuild/notarytool are Apple tools)." >&2
  echo "              The release workflow runs this step on a macos-latest runner." >&2
  exit 1
fi

[[ -n "$BINARY" ]] || BINARY="${OUT}/tlp-connector_darwin_${ARCH}"
[[ -f "$BINARY" ]] || { echo "build-pkg.sh: $BINARY not found - run build/build.sh first" >&2; exit 1; }

# productbuild's version must be numeric-ish; strip a leading v and any pre-release suffix.
PKG_VERSION="${VERSION#v}"
PKG_VERSION="${PKG_VERSION%%-*}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
ROOTDIR="${WORK}/root"
SCRIPTS="${WORK}/scripts"
RESOURCES="${WORK}/resources"

mkdir -p "${ROOTDIR}/usr/local/bin" \
         "${ROOTDIR}/Library/LaunchDaemons" \
         "${ROOTDIR}/Library/LaunchAgents" \
         "$SCRIPTS" "$RESOURCES" "$OUT"

# ---------------------------------------------------------------------------
# Payload
# ---------------------------------------------------------------------------
install -m 0755 "$BINARY" "${ROOTDIR}/usr/local/bin/tlp-connector"
# 0644 root:wheel - launchd refuses a group/world-writable daemon plist. postinstall
# re-asserts this, because a payload's recorded ownership can be lost in transit.
install -m 0644 "${HERE}/com.trackolap.connector.plist"      "${ROOTDIR}/Library/LaunchDaemons/"
install -m 0644 "${HERE}/com.trackolap.connector.tray.plist" "${ROOTDIR}/Library/LaunchAgents/"

install -m 0755 "${HERE}/scripts/preinstall"  "${SCRIPTS}/preinstall"
install -m 0755 "${HERE}/scripts/postinstall" "${SCRIPTS}/postinstall"

cat > "${RESOURCES}/welcome.html" <<EOF
<html><body style="font-family:-apple-system,Helvetica,sans-serif">
<h2>TrackOlap Connector ${VERSION}</h2>
<p>This installs a background service that reads the business applications you configure
(for example Tally on <code>localhost:9000</code>) and syncs them to your TrackOlap tenant
over HTTPS.</p>
<p>It runs as a system service and stores its configuration in
<code>/Library/Application Support/TrackOlap/Connector</code>.</p>
</body></html>
EOF

cat > "${RESOURCES}/conclusion.html" <<'EOF'
<html><body style="font-family:-apple-system,Helvetica,sans-serif">
<h2>Installed</h2>
<p>The connector is running as a background service.</p>
<p>If you have not paired this machine yet, open Terminal and run:</p>
<pre>sudo /usr/local/bin/tlp-connector -pair YOUR-PAIRING-CODE</pre>
<p>To check it over:</p>
<pre>sudo /usr/local/bin/tlp-connector -doctor</pre>
</body></html>
EOF

# ---------------------------------------------------------------------------
# Sign the binary (hardened runtime) - required before the .pkg can be notarised
# ---------------------------------------------------------------------------
if [[ -n "${MACOS_APP_IDENTITY:-}" ]]; then
  echo "==> codesigning the binary"
  # --options runtime enables the hardened runtime; notarisation REJECTS a binary without
  # it. --timestamp binds a trusted time so the signature outlives the certificate.
  codesign --force --timestamp --options runtime \
           --sign "$MACOS_APP_IDENTITY" \
           "${ROOTDIR}/usr/local/bin/tlp-connector"
  codesign --verify --strict --verbose=2 "${ROOTDIR}/usr/local/bin/tlp-connector"
else
  echo "==> WARNING: MACOS_APP_IDENTITY not set - the binary is UNSIGNED."
  echo "==>          Notarisation will be impossible and Gatekeeper will block it."
fi

# ---------------------------------------------------------------------------
# Component package
# ---------------------------------------------------------------------------
COMPONENT="${WORK}/connector-component.pkg"
echo "==> pkgbuild"
pkgbuild \
  --root "$ROOTDIR" \
  --scripts "$SCRIPTS" \
  --identifier "$IDENTIFIER" \
  --version "$PKG_VERSION" \
  --install-location "/" \
  --ownership recommended \
  "$COMPONENT"

# ---------------------------------------------------------------------------
# Product archive
# ---------------------------------------------------------------------------
DIST="${WORK}/distribution.xml"
case "$ARCH" in
  arm64) HOST_ARCHITECTURE=arm64 ;;
  amd64) HOST_ARCHITECTURE=x86_64 ;;
  *) echo "Unsupported macOS architecture: $ARCH" >&2; exit 2 ;;
esac
sed -e "s/BUNDLE_VERSION/${PKG_VERSION}/g" -e "s/HOST_ARCHITECTURE/${HOST_ARCHITECTURE}/g" "${HERE}/distribution.xml" > "$DIST"

PKG="${OUT}/tlp-connector-${PKG_VERSION}-${ARCH}.pkg"
UNSIGNED="${WORK}/product-unsigned.pkg"

echo "==> productbuild"
productbuild \
  --distribution "$DIST" \
  --package-path "$WORK" \
  --resources "$RESOURCES" \
  "$UNSIGNED"

if [[ -n "${MACOS_INSTALLER_IDENTITY:-}" ]]; then
  echo "==> signing the installer"
  productsign --sign "$MACOS_INSTALLER_IDENTITY" --timestamp "$UNSIGNED" "$PKG"
  pkgutil --check-signature "$PKG"
else
  cp "$UNSIGNED" "$PKG"
  cat >&2 <<EOF

  ############################################################################
  #  WARNING: ${PKG##*/} IS NOT SIGNED
  #
  #  macOS 10.15+ REFUSES to run an un-notarised installer, and notarisation
  #  requires a Developer ID signature first. This .pkg will only install on a
  #  machine where someone right-clicks -> Open and accepts the warning, or
  #  where Gatekeeper has been disabled.
  #
  #  Usable for local testing. NEVER ship it.
  #  Set MACOS_INSTALLER_IDENTITY ("Developer ID Installer: ...") to sign.
  #  See build/README.md.
  ############################################################################

EOF
fi

# ---------------------------------------------------------------------------
# Notarisation (guarded)
# ---------------------------------------------------------------------------
notarise() {
  local target="$1"
  echo "==> submitting to notarytool (this takes a few minutes)"
  if [[ -n "${NOTARY_PROFILE:-}" ]]; then
    xcrun notarytool submit "$target" --keychain-profile "$NOTARY_PROFILE" --wait
  else
    xcrun notarytool submit "$target" \
      --apple-id "$NOTARY_APPLE_ID" \
      --team-id "$NOTARY_TEAM_ID" \
      --password "$NOTARY_PASSWORD" \
      --wait
  fi
  # Stapling matters: without it the customer's Mac must reach Apple at install time to
  # check the notarisation, and an offline or firewalled machine simply fails.
  echo "==> stapling"
  xcrun stapler staple "$target"
  xcrun stapler validate "$target"
}

if [[ -z "${MACOS_INSTALLER_IDENTITY:-}" ]]; then
  echo "==> skipping notarisation: the package is not signed (nothing to notarise)."
elif [[ -n "${NOTARY_PROFILE:-}" ]] || [[ -n "${NOTARY_APPLE_ID:-}" && -n "${NOTARY_TEAM_ID:-}" && -n "${NOTARY_PASSWORD:-}" ]]; then
  notarise "$PKG"
  echo "==> notarised and stapled"
else
  cat >&2 <<EOF

  ############################################################################
  #  WARNING: ${PKG##*/} IS SIGNED BUT NOT NOTARISED
  #
  #  Gatekeeper on macOS 10.15+ blocks un-notarised installers even when they
  #  are correctly signed. Customers will see "cannot be opened because Apple
  #  cannot check it for malicious software".
  #
  #  Set NOTARY_PROFILE, or NOTARY_APPLE_ID + NOTARY_TEAM_ID + NOTARY_PASSWORD.
  #  See build/README.md.
  ############################################################################

EOF
fi

shasum -a 256 "$PKG" | tee "${PKG}.sha256"
echo "==> built ${PKG}"
