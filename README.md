# TrackOlap Local Connector

<img src="assets/connector.png" alt="TrackOlap Local Connector" width="128" height="128">

Install the TrackOlap background agent to synchronize local Tally customer ledgers with your TrackOlap account. It initiates outbound connections to TrackOlap; Tally does not need to be exposed to the internet.

This public repository distributes **end-user builds and installation instructions only**. Application source, icons, tests and all packaging scripts are maintained in the separate `trackolap-connector` repository. Download packages from [GitHub Releases](https://github.com/Kaptune/trackolap-local-connector/releases).

## Downloads

Version: **1.0.0**. Read the [release notes](releases/1.0.0.md). Assets become publicly downloadable when the release is published; drafts are visible only to maintainers.

| Platform | Architecture | Installer |
| --- | --- | --- |
| Windows | Intel/AMD 64-bit | `tlp-connector-1.0.0-x64.msi` |
| Windows | Intel/AMD 32-bit | `tlp-connector-1.0.0-x86.msi` |
| Windows | ARM64 | `tlp-connector-1.0.0-arm64.msi` |
| macOS | Apple silicon | `tlp-connector-1.0.0-arm64.pkg` |
| macOS | Intel | `tlp-connector-1.0.0-amd64.pkg` |
| Debian / Ubuntu | AMD64 | `tlp-connector_1.0.0_amd64.deb` |
| Debian / Ubuntu | ARM64 | `tlp-connector_1.0.0_arm64.deb` |
| RPM-based Linux | AMD64 | `tlp-connector-1.0.0-1.x86_64.rpm` |
| RPM-based Linux | ARM64 | `tlp-connector-1.0.0-1.aarch64.rpm` |

Standalone binaries and ZIP / TAR.GZ archives are supplied for all seven targets. Windows archive names use `amd64` for x64 and `386` for x86. Archives contain the executable; installers also configure the service.

**Initial build status:** evaluation builds, without Windows Authenticode signing or macOS Developer ID signing/notarization. Automatic updates are disabled because no update verification key is pinned. Operating systems may warn about or block these packages. Do not disable system security to install them.

## Before installation

- Obtain a one-time pairing code and API server URL from your TrackOlap administrator. Codes expire after 15 minutes and belong to the environment where they were created.
- Use Windows 10+/Server 2016+, [macOS 12+ for these Go 1.26 binaries](https://go.dev/doc/go1.26#darwin), or a supported Linux system matching your package architecture.
- Allow outbound HTTPS to your API host and synchronize the system clock.
- For Tally, install on the Tally PC, enable its HTTP interface on port 9000, and leave the required company open. The backend must have connector support deployed.

## Windows

Run the MSI matching your architecture as administrator. It installs the automatic `tlp-connector` service, displayed as **TrackOlap Connector**.

Unattended x64 installation, from an elevated Command Prompt:

```bat
msiexec /i "tlp-connector-1.0.0-x64.msi" /qn PAIRCODE="YOUR-PAIRING-CODE" SERVERURL="https://YOUR-API-HOST"
```

To pair later, run from the installation folder in an elevated Command Prompt:

```bat
tlp-connector.exe -pair "YOUR-PAIRING-CODE" -server "https://YOUR-API-HOST"
tlp-connector.exe -service restart
tlp-connector.exe -service status
```

The usual folder is `C:\Program Files\TrackOlap\Connector`; x86 uses `C:\Program Files (x86)\TrackOlap\Connector` on 64-bit Windows. The service redeems the staged code on startup.

## macOS

Choose the Apple silicon or Intel PKG. For a package approved by your administrator:

```sh
sudo installer -pkg ./tlp-connector-1.0.0-arm64.pkg -target /
sudo /usr/local/bin/tlp-connector -pair "YOUR-PAIRING-CODE" -server "https://YOUR-API-HOST"
sudo launchctl kickstart -k system/com.trackolap.connector
```

Use `amd64` in the package filename for Intel. The package installs a LaunchDaemon. macOS agent builds do not remove Tally's current same-machine Windows setup requirement.

## Linux

Debian / Ubuntu, substituting `arm64` when appropriate:

```sh
sudo apt install ./tlp-connector_1.0.0_amd64.deb
```

RPM-based systems, substituting `aarch64` when appropriate:

```sh
sudo dnf install ./tlp-connector-1.0.0-1.x86_64.rpm
```

Pair as the service account so credential ownership is correct:

```sh
sudo -u trackolap-connector /usr/bin/tlp-connector -pair "YOUR-PAIRING-CODE" -server "https://YOUR-API-HOST"
sudo systemctl enable tlp-connector
sudo systemctl restart tlp-connector
sudo systemctl status tlp-connector
```

Use the package manager for Linux updates. Linux packages do not add SQL/ODBC connector implementations.

## First sync

Ask your administrator to add an enabled Tally source with host `127.0.0.1`, port `9000`, the Tally company and a customer owner. Trigger **Sync now** and check the activity and imported customers. Portal availability depends on your frontend version; the backend also supports administrator API setup.

Version 1.0.0 requires an explicit sync command; scheduled synchronization is not implemented. It reads Tally data and does not write back to Tally.

## Verify downloads

Download `SHA256SUMS` with the files. Linux can verify the downloaded subset:

```sh
sha256sum --ignore-missing -c SHA256SUMS
```

On macOS, compare the output with the matching entry in `SHA256SUMS`:

```sh
shasum -a 256 tlp-connector-1.0.0-arm64.pkg
```

On Windows PowerShell:

```powershell
Get-FileHash .\tlp-connector-1.0.0-x64.msi -Algorithm SHA256
```

Checksums detect corruption; they are not publisher signatures.

## Diagnostics

The local console is restricted to loopback and a per-run token. In this build, launching a second `-console` or `-doctor` process while the service owns its database can fail with a lock timeout. For CLI diagnostics, stop the service, run `-doctor`, then start it again. Use the same state directory and, on Linux, the `trackolap-connector` service account.

| Platform | State and logs |
| --- | --- |
| Windows | `%ProgramData%\TrackOlap\Connector` |
| macOS | `/Library/Application Support/TrackOlap/Connector` |
| Linux | `/var/lib/trackolap-connector`; `journalctl -u tlp-connector` |

Keep pairing codes and configuration files private. Uninstall normally preserves the agent identity; ask your administrator to revoke the agent before permanently retiring it. These builds have no desktop tray icon.

For support, contact your TrackOlap administrator or [TrackOlap](https://www.trackolap.com).

## About this repository

Releases are prepared and uploaded manually. This repository contains no build scripts or CI/CD workflows. Installers are release assets, not application source or files committed to Git history. The new repository icon is used by refreshed builds; existing draft installers retain the artwork they were built with until a complete replacement build is uploaded.
