# Windows service, tray and setup

The Windows desktop build has two processes. `tlp-connector.exe` runs as the automatic
Windows service under `NT SERVICE\tlp-connector`. `tlp-connector-tray.exe` runs in each
signed-in user's desktop. Closing the window hides it; signing out or exiting a tray
process does not stop the service. Windows restarts the service after a crash.

## Install and pair

Use the standalone `tlp-connector-1.0.4-x64-setup.exe` (x86 and ARM64 also available).
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
  Use **Start service** in this window (administrator permission required).

There is no embedded browser dependency and no second copy of the agent database.
The status refreshes every five seconds. Last successful sync is stored per data source
and survives a service restart. Heartbeats and TCP connectivity tests are not presented
as successful data syncs. An unused generic proxy can therefore show `Not yet` for sync
while its heartbeat is current.

## Stop Application and Reset

Both buttons are available in the tray window before and after pairing. They ask for
confirmation and Windows administrator permission. Cancelling makes no changes.

- **Stop Application** stops the background service, ends active connections and closes
  this tray app. It preserves configuration. To resume, open the installed tray app and
  click **Start service**, or start TrackOlap Connector in Windows Services. The service
  still starts automatically after a Windows reboot; Stop does not uninstall it.
- **Reset** stops the service and waits for its process to exit, removes local pairing,
  host, targets and the cached-work database, then restarts unconfigured with a red icon.
  Enter a fresh pairing code to reconnect. Logs and the portal's connector record/history
  are retained; reset does not revoke or delete that remote record. If file removal fails,
  the service remains stopped and the error is shown.

Reset is supported for the standard installed ProgramData state directory. It does not
recursively delete folders or follow linked state directories. Other logged-in users'
tray windows refresh to the new service state.

## Pairing troubleshooting

The host and code stay in the window after a failed attempt; the code is cleared only
when the service confirms it is configured. Errors identify API rejection, server,
response, rate-limit, network or timeout failures without showing credentials.

If the portal shows **paired** while the tray reports **Pairing failed**, do not keep
retrying the same code. Pairing status means the server registered the computer;
**Online** and a recent heartbeat confirm the agent received working credentials.
The administrator must deploy the backend pending-activation result fix, then create
a fresh connector/code for an installation affected by that bug. Upgrading the tray
alone does not repair a code whose enrollment response was lost or rejected.

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
The ordinary tray cannot read API credentials or export the local console token. The
interactive-user named pipe still supports only status and initial pairing. Stop, start
and reset run in a separate administrator helper after UAC approval, using the installed
service registration and fixed action names. A shared operation lock excludes concurrent
setup/reset/stop operations. Pairing requests are serialized inside the service.
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
Verify Stop closes the tray and stops the service without deleting configuration; test
Start service, Reset while paired/unpaired/stopped, UAC cancellation, partial-reset
errors, fresh-code pairing after reset, and automatic startup after reboot.
Also verify standard-user pairing/status and that the service's credential directory
cannot be read by an ordinary local user. Cross-compilation and local tests do not
replace these Windows checks.
