# Windows service, tray and setup

The Windows desktop build has two processes. `tlp-connector.exe` runs as the automatic
Windows service under `NT SERVICE\tlp-connector`. `tlp-connector-tray.exe` runs in each
signed-in user's desktop. Closing the window hides it; signing out or exiting a tray
process does not stop the service. Windows restarts the service after a crash.

## Install and pair

Use the standalone `tlp-connector-1.0.2-x64-setup.exe` (x86 and ARM64 also available).
Run it, accept installation and Windows administrator elevation. Setup installs the
service and tray, registers tray startup for sign-in, and opens the tray without
administrator elevation. These builds are unsigned evaluation installers; Windows
may warn about or block them. Do not bypass your organization's security policy.

Click the tray icon to open the small native window:

- **Red, not configured:** enter the HTTPS API host (a bare hostname is accepted),
  pairing code, then **Start**. A rejected/expired code leaves the form available with
  an error; it does not stop the background service.
- **Green, configured:** shows host, connector ID, service/connection status, last
  successful sync, last accepted heartbeat and agent version. Green describes pairing,
  not internet availability; the window distinguishes offline, paused and connected.
- **Service unavailable:** red with an explanation; the tray retries automatically.
  Start TrackOlap Connector in Windows Services if it has been stopped manually.

There is no embedded browser dependency and no second copy of the agent database.
The status refreshes every five seconds. Last successful sync is stored per data source
and survives a service restart. Heartbeats and TCP connectivity tests are not presented
as successful data syncs. An unused generic proxy can therefore show `Not yet` for sync
while its heartbeat is current.

## Updates and uninstall

Run a newer setup of the same architecture to update. Setup stops the service before
replacing its executable, preserves `%ProgramData%\TrackOlap\Connector`, then restarts
it. To switch architecture or migrate an MSI-managed installation, uninstall that
installation first; pairing state is preserved. Do not mix MSI and standalone-setup
ownership of one installation.

Use **Windows Settings → Apps → TrackOlap Local Connector → Uninstall**. The service
and tray startup are removed. Configuration is retained for reinstall; revoke the agent
in the portal before permanently retiring the machine. Files still in use may need a
Windows restart before cleanup finishes.

## Local control boundary

The tray receives a narrow status snapshot and can pair only an unconfigured service.
It cannot read the API token/secret, export the local console token, stop the service,
or replace an existing enrollment. Pairing requests are serialized inside the service.
The [Windows named pipe](https://learn.microsoft.com/en-us/windows/win32/ipc/named-pipe-security-and-access-rights)
allows local interactive users, administrators and the service identity. Remote pipe
clients are rejected. Interactive access excludes permission to create pipe instances.
The tray checks the pipe server PID against Windows Service Control Manager before
sending a pairing code. Requests and responses are bounded, requests time out, and
only eight simultaneous local requests are accepted.

## Windows acceptance checks (not yet executed)

No Windows machine was available during implementation. Before production use, verify
on each supported architecture: clean install/UAC, pairing and rejected code, green/red
tray state, Explorer restart, network loss/recovery, reboot/login, signed-out service
operation, service crash recovery, upgrade with identity preserved, and uninstall.
Also verify standard-user pairing/status and that the service's credential directory
cannot be read by an ordinary local user. Cross-compilation and local tests do not
replace these Windows checks.
