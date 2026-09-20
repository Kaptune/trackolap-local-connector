# Install and maintain a connector

[Platform guide](README.md) · [Downloads](DOWNLOADS.md) · [Windows desktop guide](WINDOWS_INSTALL.md)

Install the connector on a computer that can stay running and reach your approved
local services. The operating system determines installation and service management;
pairing, target approval and HTTP/TCP tests use the same TrackOlap portal workflow.

## Before installation

- Ask your TrackOlap administrator to enable Local Connectors, open **Admin → Local Connectors**, and add a connector to obtain a one-time pairing code.
- Obtain the API server URL for the same environment. Pairing codes expire after 15 minutes.
- Use Windows 10+/Server 2016+, macOS 12+, or Linux matching the download architecture.
- Allow outbound HTTPS to your API host and synchronize the system clock.
- Install on a computer that can reach the HTTP/TCP destinations you want to approve. `127.0.0.1` always means that connector computer.

## Windows desktop installation

Download the standalone setup for your architecture from [Downloads](DOWNLOADS.md),
then follow the [Windows service and tray guide](WINDOWS_INSTALL.md). It covers pairing,
background startup, upgrades, Stop Application and Reset.

## macOS

Choose the Apple silicon or Intel PKG from [Downloads](DOWNLOADS.md). In the command below, replace `VERSION` with the downloaded release version:

```sh
sudo installer -pkg ./tlp-connector-VERSION-arm64.pkg -target /
sudo /usr/local/bin/tlp-connector -pair "YOUR-PAIRING-CODE" -server "https://YOUR-API-HOST"
sudo launchctl kickstart -k system/com.trackolap.connector
```

Use `amd64` in the filename for Intel. The package installs a LaunchDaemon.

## Linux

Use the package from [Downloads](DOWNLOADS.md). Replace `VERSION` with its release version and choose the correct architecture.

Debian / Ubuntu, substituting `arm64` when appropriate:

```sh
sudo apt install ./tlp-connector_VERSION_amd64.deb
```

RPM-based systems, substituting `aarch64` when appropriate:

```sh
sudo dnf install ./tlp-connector-VERSION-1.x86_64.rpm
```

For a new installation, pair as the service account:

```sh
sudo -u trackolap-connector /usr/bin/tlp-connector -pair "YOUR-PAIRING-CODE" -server "https://YOUR-API-HOST"
sudo systemctl enable tlp-connector
sudo systemctl restart tlp-connector
sudo systemctl status tlp-connector
```

Upgrade an existing installation using its package manager. Keep its state directory to preserve pairing; do not issue a new pairing code for a routine upgrade.

## Confirm setup

Open **Admin → Local Connectors**, select the connector and confirm **Online** with a
recent **Last seen** value. Pairing alone does not confirm connectivity. Follow the
[platform guide](README.md#configure-and-test-connectivity) to approve targets and test them.

## Platform administration

Your TrackOlap administrator must enable Local Connectors and use compatible API,
portal and agent releases. The backend HTTP/TCP relay must also be enabled for tests
(`-Dconnector.tcp.enabled=true`). If a control is unavailable, ask the administrator to
check feature availability and the connector's reported capabilities.

## Diagnostics and state

The local console is loopback-only and requires a per-run token. A second console/doctor process can conflict with the running service's database lock. For CLI diagnostics, stop the service, run `-doctor` using the same state directory and service account, then start the service again.

| Platform | State and logs |
| --- | --- |
| Windows | `%ProgramData%\TrackOlap\Connector` |
| macOS | `/Library/Application Support/TrackOlap/Connector` |
| Linux | `/var/lib/trackolap-connector`; `journalctl -u tlp-connector` |

Keep pairing codes and configuration files private. Uninstall normally preserves the agent identity; ask your administrator to revoke the agent before permanently retiring it. The Windows desktop setup includes the tray UI; macOS/Linux packages run without a desktop tray. For support, contact your TrackOlap administrator or [TrackOlap](https://www.trackolap.com).
