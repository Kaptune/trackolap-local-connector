#!/usr/bin/env bash
#
# build/linux/package.sh - build the .deb and .rpm for every Linux architecture.
#
# Runs anywhere nfpm runs (a single Go binary), so the Linux packages come out of the same
# CI job that cross-compiles the binaries - no dpkg-dev, no rpmbuild, no matching host
# distro, no container per format.
#
# Usage:
#   build/linux/package.sh -v 1.4.2                 # amd64 + arm64, deb + rpm
#   build/linux/package.sh -v 1.4.2 -a amd64        # one architecture
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG="${ROOT}/build/linux/nfpm.yaml"
OUT="${ROOT}/dist"
VERSION=""
ARCHES=(amd64 arm64)
FORMATS=(deb rpm)

usage() {
  cat >&2 <<'EOF'
usage: package.sh -v VERSION [-a ARCH] [-f FORMAT] [-o OUTDIR]
  -a  amd64 | arm64        (default: both)
  -f  deb | rpm            (default: both)
EOF
  exit "${1:-2}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--version) VERSION="$2"; shift 2 ;;
    -a|--arch)    ARCHES=("$2"); shift 2 ;;
    -f|--format)  FORMATS=("$2"); shift 2 ;;
    -o|--out)     OUT="$2"; shift 2 ;;
    -h|--help)    usage 0 ;;
    *) echo "package.sh: unknown option $1" >&2; usage ;;
  esac
done

[[ -n "$VERSION" ]] || { echo "package.sh: -v VERSION is required" >&2; usage; }

if ! command -v nfpm >/dev/null 2>&1; then
  cat >&2 <<'EOF'
package.sh: nfpm is not installed.

  go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest

It is a single Go binary and produces both .deb and .rpm on any host, which is why the
Linux packages can be built in the same job as the cross-compiled binaries.
EOF
  exit 1
fi

# .deb and .rpm versions must not carry a leading "v". A pre-release suffix is kept, since
# both formats can express one (unlike MSI).
PKG_VERSION="${VERSION#v}"

mkdir -p "$OUT"
cd "$ROOT"   # nfpm.yaml's `src:` paths are repo-relative
RENDERED_CONFIG="$(mktemp)"
trap 'rm -f "$RENDERED_CONFIG"' EXIT

for arch in "${ARCHES[@]}"; do
  binary="${OUT}/tlp-connector_linux_${arch}"
  if [[ ! -f "$binary" ]]; then
    echo "package.sh: $binary not found - run build/build.sh first" >&2
    exit 1
  fi
  # nFPM expands package metadata, but not contents.src. Render only that path.
  python3 - "$CONFIG" "$RENDERED_CONFIG" "$binary" <<'PY'
import json
from pathlib import Path
import sys
text = Path(sys.argv[1]).read_text()
text = text.replace('"${DIST}/tlp-connector_linux_${ARCH}"', json.dumps(sys.argv[3]))
Path(sys.argv[2]).write_text(text)
PY
  for fmt in "${FORMATS[@]}"; do
    echo "==> ${fmt} ${arch} ${PKG_VERSION}"
    VERSION="$PKG_VERSION" ARCH="$arch" DIST="$OUT" \
      nfpm package -f "$RENDERED_CONFIG" -p "$fmt" -t "$OUT"
  done
done

echo
echo "==> Linux packages in ${OUT}:"
ls -1 "$OUT" | grep -E '\.(deb|rpm)$' | sed 's/^/    /'

cat <<'EOF'

Signing:
  .deb  repository-level, by signing the apt Release file (reprepro/aptly), not the .deb.
  .rpm  package-level:  rpm --addsign dist/*.rpm   (needs a gpg key in the build keyring)
Both are guarded no-ops here - see build/README.md for the release procedure.
EOF
