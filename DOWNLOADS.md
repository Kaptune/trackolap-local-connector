# Connector downloads

[Platform guide](README.md) · [Installation](INSTALLATION.md) · [All releases](https://github.com/Kaptune/trackolap-local-connector/releases)

Choose the package for the operating system and architecture of the computer running
the connector. Platform releases can have different versions. The platform guide
explains shared capabilities; each release describes its package-specific changes.

## Windows desktop installer — 1.0.4

The standalone EXE installs the background service and tray app. Choose the same
architecture as your existing installation when upgrading.

| Windows architecture | Standalone installer |
| --- | --- |
| Intel/AMD 64-bit | [Download x64 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.4/tlp-connector-1.0.4-x64-setup.exe) |
| Intel/AMD 32-bit | [Download x86 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.4/tlp-connector-1.0.4-x86-setup.exe) |
| ARM64 | [Download ARM64 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.4/tlp-connector-1.0.4-arm64-setup.exe) |

See the [Windows guide](WINDOWS_INSTALL.md) and [release notes](releases/1.0.4.md).
These installers are unsigned evaluation previews. Compilation and automated checks
passed; installation, reboot, UAC and tray behavior still require Windows runtime
validation. MSI packaging for this desktop release remains pending.

## Multi-platform downloads — 1.0.1

Version **1.0.1**, evaluation prerelease. See the [release notes](https://github.com/Kaptune/trackolap-local-connector/blob/main/releases/1.0.1.md) and [all downloads](https://github.com/Kaptune/trackolap-local-connector/releases/tag/v1.0.1).

| Platform | Architecture | Download |
| --- | --- | --- |
| Windows | Intel/AMD 64-bit | [tlp-connector_windows_amd64.zip](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.1/tlp-connector_windows_amd64.zip) |
| Windows | Intel/AMD 32-bit | [tlp-connector_windows_386.zip](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.1/tlp-connector_windows_386.zip) |
| Windows | ARM64 | [tlp-connector_windows_arm64.zip](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.1/tlp-connector_windows_arm64.zip) |
| macOS | Apple silicon | [tlp-connector-1.0.1-arm64.pkg](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.1/tlp-connector-1.0.1-arm64.pkg) |
| macOS | Intel | [tlp-connector-1.0.1-amd64.pkg](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.1/tlp-connector-1.0.1-amd64.pkg) |
| Debian / Ubuntu | AMD64 | [tlp-connector_1.0.1_amd64.deb](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.1/tlp-connector_1.0.1_amd64.deb) |
| Debian / Ubuntu | ARM64 | [tlp-connector_1.0.1_arm64.deb](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.1/tlp-connector_1.0.1_arm64.deb) |
| RPM-based Linux | AMD64 | [tlp-connector-1.0.1-1.x86_64.rpm](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.1/tlp-connector-1.0.1-1.x86_64.rpm) |
| RPM-based Linux | ARM64 | [tlp-connector-1.0.1-1.aarch64.rpm](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.1/tlp-connector-1.0.1-1.aarch64.rpm) |

Standalone binaries and ZIP / TAR.GZ archives are available for all seven platform/architecture combinations. **Windows MSI installers for 1.0.1 are pending a Windows packaging host**; the Windows downloads above are portable agents and do not install a service automatically. Older 1.0.0 MSIs do not contain these changes.

These evaluation builds have no Windows Authenticode signature or macOS Developer ID signing/notarization. Automatic updates are disabled; upgrades are manual. Operating systems may warn about or block unsigned packages. Do not disable system security to install them.

## Verify downloads

Download `SHA256SUMS` with the assets. On Linux:

```sh
sha256sum --ignore-missing -c SHA256SUMS
```

On macOS, compare this output with its entry in `SHA256SUMS`:

```sh
shasum -a 256 tlp-connector-1.0.1-arm64.pkg
```

On Windows PowerShell:

```powershell
Get-FileHash .\tlp-connector_windows_amd64.zip -Algorithm SHA256
```

Checksums detect corruption; they are not publisher signatures. `BUILDINFO.json` records the source revision, toolchain and validation scope.

Release assets include build-time documentation snapshots. Use the repository's
[platform guide](README.md) and [installation guide](INSTALLATION.md) for current
instructions. Releases are built and published manually.
