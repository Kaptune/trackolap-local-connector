# TrackOlap Local Connector

<img src="assets/connector.png" alt="TrackOlap Local Connector" width="128" height="128">

Install the TrackOlap background agent to securely reach approved HTTP and TCP services on your local network. The agent initiates outbound HTTPS connections to TrackOlap; local services do not need public inbound ports.

This public repository contains **end-user downloads and installation instructions only**. Application source and packaging are maintained separately in `trackolap-connector`. Releases are built and published manually; there is no CI/CD.

## Windows service and tray preview — 1.0.4

The new Windows installer runs the connector as a background service, starts it with
Windows, and adds a tray app at sign-in. The tray is **red before pairing** and **green
when configured**. Click it to enter the API host and code, or view connector ID,
connection status, last successful sync and heartbeat. Closing the window keeps the
service running. **Stop Application** stops the service and exits the tray; **Reset**
clears local configuration and cached work, then restarts ready for a fresh pairing
code. Both controls request confirmation and administrator permission.

| Windows architecture | Standalone installer |
| --- | --- |
| Intel/AMD 64-bit | [Download x64 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.4/tlp-connector-1.0.4-x64-setup.exe) |
| Intel/AMD 32-bit | [Download x86 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.4/tlp-connector-1.0.4-x86-setup.exe) |
| ARM64 | [Download ARM64 setup](https://github.com/Kaptune/trackolap-local-connector/releases/download/v1.0.4/tlp-connector-1.0.4-arm64-setup.exe) |

**Unsigned Windows preview:** compilation, package inspection and local automated tests
passed; the updated Windows installation, reboot and tray behavior still require
validation on Windows. See the [Windows installation guide](WINDOWS_INSTALL.md)
and [1.0.4 release notes](releases/1.0.4.md). These are self-contained EXE installers;
MSI packaging remains pending. The existing macOS/Linux downloads below remain at 1.0.1.

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

Standalone binaries and ZIP / TAR.GZ archives are available for all seven targets. **Windows MSI installers for 1.0.1 are pending a Windows packaging host**; the Windows downloads above are portable agents and do not install a service automatically. Older 1.0.0 MSIs do not contain these changes.

These evaluation builds have no Windows Authenticode signature or macOS Developer ID signing/notarization. Automatic updates are disabled; upgrades are manual. Operating systems may warn about or block unsigned packages. Do not disable system security to install them.

## Before installation

- Ask your TrackOlap administrator to enable Local Connectors, open **Admin → Local Connectors**, and add a connector to obtain a one-time pairing code.
- Obtain the API server URL for the same environment. Pairing codes expire after 15 minutes.
- Use Windows 10+/Server 2016+, macOS 12+, or Linux matching the download architecture.
- Allow outbound HTTPS to your API host and synchronize the system clock.
- Install on a computer that can reach the HTTP/TCP destinations you want to approve. `127.0.0.1` always means that connector computer.

## Windows portable agent

Extract the ZIP to a dedicated folder. From an elevated Command Prompt in that folder, use the executable matching your download; this example is x64:

```bat
tlp-connector_windows_amd64.exe -version
tlp-connector_windows_amd64.exe -pair "YOUR-PAIRING-CODE" -server "https://YOUR-API-HOST"
tlp-connector_windows_amd64.exe
```

The last command runs in the foreground. Leave it running for connectivity; Ctrl+C stops it. Use `386` for x86 or `arm64` for ARM64. Do not run a second agent against the same state directory while an existing connector service is running. Persistent Windows service installation via MSI is pending.

## macOS

Choose the Apple silicon or Intel PKG approved by your administrator:

```sh
sudo installer -pkg ./tlp-connector-1.0.1-arm64.pkg -target /
sudo /usr/local/bin/tlp-connector -pair "YOUR-PAIRING-CODE" -server "https://YOUR-API-HOST"
sudo launchctl kickstart -k system/com.trackolap.connector
```

Use `amd64` in the filename for Intel. The package installs a LaunchDaemon.

## Linux

Debian / Ubuntu, substituting `arm64` when appropriate:

```sh
sudo apt install ./tlp-connector_1.0.1_amd64.deb
```

RPM-based systems, substituting `aarch64` when appropriate:

```sh
sudo dnf install ./tlp-connector-1.0.1-1.x86_64.rpm
```

For a new installation, pair as the service account:

```sh
sudo -u trackolap-connector /usr/bin/tlp-connector -pair "YOUR-PAIRING-CODE" -server "https://YOUR-API-HOST"
sudo systemctl enable tlp-connector
sudo systemctl restart tlp-connector
sudo systemctl status tlp-connector
```

Upgrade an existing installation using its package manager. Keep its state directory to preserve pairing; do not issue a new pairing code for a routine upgrade.

## Configure and test connectivity

1. Open the paired connector's detail page and wait for it to show online.
2. Under **Approved targets**, add an alias, literal destination IP address, and port. Wait for its status to become **Applied**. Deleting a target blocks new connections and closes the agent's current tunnel generation; applications may need to reconnect.
3. Use **HTTP test** for a method, relative path, headers and body, or **TCP test** to check socket connectivity. A TCP success does not execute a SQL query or authenticate to the destination application.
4. Review **HTTP / TCP traffic** and **Recent activity** for results, duration and socket IPs. HTTP test bodies are transient; raw TCP payloads are not retained in traffic logs.

Portal target management requires the matching backend/frontend deployment and the Local Connector feature flag. HTTP/TCP tests additionally require backend `connector.tcp.enabled=true`. New targets are delivered through configuration polling, then confirmed by heartbeat. No database-specific driver or business integration setup is required for this generic transport.

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

## Diagnostics and state

The local console is loopback-only and requires a per-run token. A second console/doctor process can conflict with the running service's database lock. For CLI diagnostics, stop the service, run `-doctor` using the same state directory and service account, then start the service again.

| Platform | State and logs |
| --- | --- |
| Windows | `%ProgramData%\TrackOlap\Connector` |
| macOS | `/Library/Application Support/TrackOlap/Connector` |
| Linux | `/var/lib/trackolap-connector`; `journalctl -u tlp-connector` |

Keep pairing codes and configuration files private. Uninstall normally preserves the agent identity; ask your administrator to revoke the agent before permanently retiring it. These builds have no desktop tray UI. For support, contact your TrackOlap administrator or [TrackOlap](https://www.trackolap.com).
