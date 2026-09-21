# Connector downloads

[Platform guide](README.md) · [Installation](INSTALLATION.md) · [All releases](https://github.com/Kaptune/trackolap-local-connector/releases)

Choose the package for the operating system and architecture of the computer running
the connector. The platform guide
explains shared capabilities; each release describes its package-specific changes.

## Latest release — 1.0.7

Install the package matching your computer. Normal upgrades preserve pairing and
approved targets. See [what's new](releases/1.0.7.md).

## Windows desktop installer — 1.0.7

The standalone EXE installs the background service and tray app. Choose the same
architecture as your existing installation when upgrading.

| Windows architecture | Standalone installer |
| --- | --- |
| Intel/AMD 64-bit | [Download x64 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.7/tlp-connector-1.0.7-x64-setup.exe) |
| Intel/AMD 32-bit | [Download x86 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.7/tlp-connector-1.0.7-x86-setup.exe) |
| ARM64 | [Download ARM64 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.7/tlp-connector-1.0.7-arm64-setup.exe) |

See the [Windows guide](WINDOWS_INSTALL.md) and [release notes](releases/1.0.7.md).
## macOS and Linux downloads — 1.0.7

| Platform | Architecture | Download |
| --- | --- | --- |
| macOS | Apple silicon | [tlp-connector-1.0.7-arm64.pkg](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.7/tlp-connector-1.0.7-arm64.pkg) |
| macOS | Intel | [tlp-connector-1.0.7-amd64.pkg](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.7/tlp-connector-1.0.7-amd64.pkg) |
| Debian / Ubuntu | AMD64 | [tlp-connector_1.0.7_amd64.deb](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.7/tlp-connector_1.0.7_amd64.deb) |
| Debian / Ubuntu | ARM64 | [tlp-connector_1.0.7_arm64.deb](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.7/tlp-connector_1.0.7_arm64.deb) |
| RPM-based Linux | AMD64 | [tlp-connector-1.0.7-1.x86_64.rpm](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.7/tlp-connector-1.0.7-1.x86_64.rpm) |
| RPM-based Linux | ARM64 | [tlp-connector-1.0.7-1.aarch64.rpm](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.7/tlp-connector-1.0.7-1.aarch64.rpm) |

Windows downloads install the background service and tray app. Standalone binaries and
TAR.GZ archives are also available for macOS and Linux. Upgrades are manual.

## Verify downloads

Download `SHA256SUMS` with the assets. On Linux:

```sh
sha256sum --ignore-missing -c SHA256SUMS
```

On macOS, compare this output with its entry in `SHA256SUMS`:

```sh
shasum -a 256 tlp-connector-1.0.7-arm64.pkg
```

On Windows PowerShell:

```powershell
Get-FileHash .\tlp-connector-1.0.7-x64-setup.exe -Algorithm SHA256
Get-AuthenticodeSignature .\tlp-connector-1.0.7-x64-setup.exe
```

Use the [installation guide](INSTALLATION.md) for setup, pairing and upgrades.
