# Release packaging

This public repository packages compiled binaries. Do not copy application source, pairing files or signing keys here.

From the separately maintained connector source, using Go 1.26.5:

```sh
make verify
./build/build.sh -v 1.0.0 --archives -o /absolute/path/to/trackolap-local-connector/dist
```

The output includes seven agent binaries and archives. Exclude `tlp-manifest` (a maintainer tool) from public downloads. Without `TLP_UPDATE_PUBKEY`, automatic updates remain disabled; do not create a throwaway signing identity to make builds appear signed.

From this repository, package macOS and Linux:

```sh
# Requires a macOS host and Apple packaging tools:
./build/macos/build-pkg.sh -v 1.0.0 -a arm64
./build/macos/build-pkg.sh -v 1.0.0 -a amd64
# Requires nfpm v2.43.4 on PATH:
./build/linux/package.sh -v 1.0.0
```

MSIs require Windows: WiX depends on native Windows components despite being a .NET tool. See the [WiX maintainer explanation](https://github.com/orgs/wixtoolset/discussions/7979).

On Windows PowerShell:

```powershell
dotnet tool install --global wix --version 5.0.2
wix extension add -g WixToolset.Util.wixext/5.0.2
wix extension add -g WixToolset.UI.wixext/5.0.2
./scripts/build-windows.ps1 -Version 1.0.0
```

## Windows CI

1. Push reviewed packaging files and the workflow to this repository.
2. Create draft release `v1.0.0`; upload compiled binaries/packages and `SHA256SUMS`.
3. Manually run **Build Windows installers**, version `1.0.0`. It verifies the three Windows input hashes, builds all MSIs, inspects architecture/version and uploads the installers plus refreshed checksums to the same draft.
4. Download and validate the resulting assets. The workflow never publishes the draft.

The workflow accesses this repository and release files only, not the application source. It does not install the connector or send notifications.

## Final checksums

```sh
python3 scripts/checksums.py dist
```

Upload `SHA256SUMS` and the files it references together. The script includes only supported release filenames, excluding private keys, signing tools, WiX debug files and old checksums. Paths are portable basenames. `BUILDINFO.json` records the source revision/toolchain; it is not a signed attestation.

## Production release prerequisites

The initial build is unsigned and unnotarized with automatic updates disabled. The inherited Windows installer license is a placeholder. Before production publication, replace it with approved terms, configure platform signing, test actual installation/uninstallation on each OS and wire up server-side expired-command recovery. Signed auto-update manifests must use the key trusted by installed agents.
