# TrackOlap Local Connector

<img src="assets/connector.png" alt="TrackOlap Local Connector" width="128" height="128">

Connect the TrackOlap platform to approved HTTP and TCP services inside your local
network. Install a connector on a computer near those services, pair it with your
TrackOlap account, and manage its destinations and connectivity from the portal.

[Download a connector](DOWNLOADS.md) · [Installation guide](INSTALLATION.md) · [Release notes](https://github.com/Kaptune/trackolap-local-connector/releases)

## What you can do

| Capability | How you use it |
| --- | --- |
| Access local HTTP/HTTPS services | Send requests to an approved destination and inspect its response. |
| Relay TCP traffic | Provide a connection to an approved local IP address and port for supported TrackOlap workflows. |
| Control destinations | Add or remove target aliases, IP addresses and ports from the portal. |
| Check availability | View pairing status, online status and the last received heartbeat. |
| Test connectivity | Use the HTTP request tester or TCP connection test on the connector detail page. |
| Review activity | Inspect HTTP/TCP traffic summaries, results, duration, socket IPs and administrative activity. |

The connector provides generic network transport. Application-specific authentication,
queries and data processing belong to the application using that connection. A successful
TCP test confirms a socket can open; it does not run a query or validate application credentials.

## How it works

1. The connector runs on a computer inside your network and initiates outbound HTTPS
   communication with TrackOlap. Your local services do not need public inbound ports.
2. Pairing associates the installed connector with a record in your TrackOlap account.
3. You approve each destination by alias, IP address and port. The connector applies
   the configuration and reports its status through heartbeats.
4. TrackOlap sends an authorized request through the connector to an approved destination.
   The connector relays the request and response over the established transport.
5. The portal shows connectivity and activity so you can diagnose failures.

The connector computer must remain running and able to reach both TrackOlap and the
local destination. A loopback address such as `127.0.0.1` means the connector computer,
not the computer displaying the portal.

## Get started

1. Ask your administrator to enable **Local Connectors** for your account and provide
   the API host for your TrackOlap environment.
2. In **Admin → Local Connectors**, choose **Add connector** and obtain a pairing code.
3. [Download](DOWNLOADS.md) and [install](INSTALLATION.md) the package for the computer's
   operating system and architecture.
4. Enter the API host and pairing code using the installed app or the platform's
   pairing command. Use the host and code from the same environment.
5. Open the connector in the portal and wait for **Online** and a recent **Last seen**.

Pairing codes are single-use and expire after 15 minutes. Keep them private.

## Configure and test connectivity

Open the connector's detail page in **Admin → Local Connectors**.

1. Under **Approved targets**, add an alias, literal destination IP address and port.
   Wait for the target to show **Applied** before testing it.
2. In **HTTP test**, select a target, choose HTTP or HTTPS, and enter the method,
   relative path, optional headers and body. Inspect the response status, headers,
   body preview and timing. HTTP requests can modify the destination according to
   the method and endpoint you choose.
3. In **TCP test**, select a target and test whether the connector can open a socket.
   This test sends no application data.
4. Use **HTTP / TCP traffic** and **Recent activity** to investigate the result.

Removing an approved target prevents new connections and can interrupt existing
connections while configuration is applied. Features and controls depend on your
account settings and compatible platform and agent versions.

## Understand connector status

| Status | Meaning |
| --- | --- |
| Pending pairing | A connector record exists, but setup has not completed. |
| Paired / configured | An identity has been registered. Check the heartbeat to confirm live connectivity. |
| Online | The platform has recently received a heartbeat from the active connector. |
| Offline | The connector is not reporting a recent heartbeat. Check the service, computer and network. |
| Last seen | The time of the last heartbeat received by TrackOlap. An empty value means no heartbeat has been received. |

A heartbeat confirms agent availability; it does not prove that every target is reachable.
Use the protocol tests to check individual destinations. A last-sync time refers to
completed data work, so it may remain empty when a connector is only used as a generic proxy.

## Delete a connector that was never seen

When supported by your platform deployment, the connector list shows **Delete** for
records with an empty **Last seen**, including paired records left by unsuccessful setup.
Confirmation removes the connector record and invalidates its identity and pairing
codes. Audit history is retained.

Previously seen connectors remain protected even when offline. If a first heartbeat
arrives before deletion completes, refresh the list and check the updated status.
Resetting an installation locally does not delete its portal record.

## Installation and ongoing operation

Windows, macOS and Linux packages share the same portal workflow. Their installation
and local controls differ:

| Platform | Local operation | Guide |
| --- | --- | --- |
| Windows desktop setup | Background service with a tray for pairing, status, Start service, Stop Application and Reset. | [Windows guide](WINDOWS_INSTALL.md) |
| macOS | Background LaunchDaemon, with command-line pairing and service management. | [macOS installation](INSTALLATION.md#macos) |
| Linux | Background systemd service, with command-line pairing and service management. | [Linux installation](INSTALLATION.md#linux) |

Upgrades are manual. Follow the installation guide to preserve your pairing configuration.
Available package formats, architectures, release versions and validation limitations
are listed on the [Downloads page](DOWNLOADS.md).

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Pairing fails | Confirm the API host and code belong to the same environment. Read the app's error; expired or consumed codes require a fresh code. |
| Portal says paired, but the app reports failure | Check whether the app saved its configuration and whether a heartbeat arrived. Ask your administrator to investigate enrollment before pairing again. |
| Connector is offline | Check that the service is running, the computer is awake, outbound HTTPS is allowed and its clock is synchronized. |
| Target stays pending | Wait for configuration and heartbeat updates; confirm the connector is online and supports portal target management. |
| TCP test fails | Check the approved IP/port, destination service and local firewall from the connector computer. |
| HTTP returns an error | Inspect the HTTP status and response preview, then check the path, method, headers and destination application. |
| A control is unavailable | Ask your administrator to check account features, platform deployment and agent compatibility. |

Traffic history contains request metadata and connection summaries; the generic test
response preview is transient, and raw TCP payloads are not retained in traffic logs.
See [diagnostics and state](INSTALLATION.md#diagnostics-and-state) for local logs. Keep
pairing codes and configuration files private when sharing diagnostic information.

## About this repository

This public repository contains end-user downloads and guides for the TrackOlap
connector. Release-specific changes are recorded in the
[release notes](https://github.com/Kaptune/trackolap-local-connector/releases).
For help with your account or deployment, contact your TrackOlap administrator or
[TrackOlap](https://www.trackolap.com).
