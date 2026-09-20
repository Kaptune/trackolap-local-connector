# Connector downloads

[Platform guide](README.md) · [Installation](INSTALLATION.md) · [All releases](https://github.com/Kaptune/trackolap-local-connector/releases)

Choose the package for the operating system and architecture of the computer running
the connector. The platform guide
explains shared capabilities; each release describes its package-specific changes.

## Latest release — 1.0.6

Upgrade installed agents before deploying a backend that removes the legacy command
poll endpoint. Existing pairing and approved targets are retained during a normal
upgrade. See [release notes](releases/1.0.6.md) for compatibility and validation details.

## Windows desktop installer — 1.0.6

The standalone EXE installs the background service and tray app. Choose the same
architecture as your existing installation when upgrading.

| Windows architecture | Standalone installer |
| --- | --- |
| Intel/AMD 64-bit | [Download x64 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.6/tlp-connector-1.0.6-x64-setup.exe) |
| Intel/AMD 32-bit | [Download x86 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.6/tlp-connector-1.0.6-x86-setup.exe) |
| ARM64 | [Download ARM64 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.6/tlp-connector-1.0.6-arm64-setup.exe) |

See the [Windows guide](WINDOWS_INSTALL.md) and [release notes](releases/1.0.6.md).
The installer, background service and tray app are signed as **Kaptune Media India
Private Limited**, using SHA-256 and Sectigo timestamps. Signatures and package checks
passed; Windows installation and runtime validation remain pending.

## macOS and Linux downloads — 1.0.6

Version **1.0.6**, evaluation prerelease. See the [release notes](https://github.com/Kaptune/trackolap-local-connector/blob/main/releases/1.0.6.md) and [all downloads](https://github.com/Kaptune/trackolap-local-connector/releases/tag/v1.0.6).

| Platform | Architecture | Download |
| --- | --- | --- |
| macOS | Apple silicon | [tlp-connector-1.0.6-arm64.pkg](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.6/tlp-connector-1.0.6-arm64.pkg) |
| macOS | Intel | [tlp-connector-1.0.6-amd64.pkg](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.6/tlp-connector-1.0.6-amd64.pkg) |
| Debian / Ubuntu | AMD64 | [tlp-connector_1.0.6_amd64.deb](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.6/tlp-connector_1.0.6_amd64.deb) |
| Debian / Ubuntu | ARM64 | [tlp-connector_1.0.6_arm64.deb](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.6/tlp-connector_1.0.6_arm64.deb) |
| RPM-based Linux | AMD64 | [tlp-connector-1.0.6-1.x86_64.rpm](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.6/tlp-connector-1.0.6-1.x86_64.rpm) |
| RPM-based Linux | ARM64 | [tlp-connector-1.0.6-1.aarch64.rpm](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.6/tlp-connector-1.0.6-1.aarch64.rpm) |

Windows is distributed only as the service-and-tray setup EXEs listed above. Portable Windows EXEs and ZIPs are no longer included in this release. Standalone binaries and TAR.GZ archives remain available for macOS and Linux.

Windows packages have Authenticode signatures. macOS packages have no Developer ID signing or notarization, and Linux packages are unsigned. This remains an evaluation prerelease. Automatic updates are disabled; upgrades are manual.

## Verify downloads

Download `SHA256SUMS` with the assets. On Linux:

```sh
sha256sum --ignore-missing -c SHA256SUMS
```

On macOS, compare this output with its entry in `SHA256SUMS`:

```sh
shasum -a 256 tlp-connector-1.0.6-arm64.pkg
```

On Windows PowerShell:

```powershell
Get-FileHash .\tlp-connector-1.0.6-x64-setup.exe -Algorithm SHA256
Get-AuthenticodeSignature .\tlp-connector-1.0.6-x64-setup.exe
```

Checksums detect corruption; they are not publisher signatures. `BUILDINFO.json` records the source revision, toolchain and validation scope.

Release assets include build-time documentation snapshots. Use the repository's
[platform guide](README.md) and [installation guide](INSTALLATION.md) for current
instructions. Releases are built and published manually.
