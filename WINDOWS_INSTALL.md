# Windows service, tray and setup

[Platform guide](README.md) · [Downloads](DOWNLOADS.md) · [Other platforms](INSTALLATION.md)

The Windows desktop build has two processes. `tlp-connector.exe` runs as the automatic
Windows service under `NT SERVICE\tlp-connector`. `tlp-connector-tray.exe` runs in each
signed-in user's desktop. Closing the window hides it; signing out or exiting a tray
process does not stop the service. Windows restarts the service after a crash.

## Install and pair

Choose the standalone setup for your architecture (x64, x86 or ARM64) from [Downloads](DOWNLOADS.md).
Run it, accept installation and Windows administrator elevation. Setup installs the
service and tray, registers tray startup for sign-in, and opens the tray without
administrator elevation. The current installer, service and tray are Authenticode-signed
as **Kaptune Media India Private Limited**. You can check the publisher under
**Properties → Digital Signatures**.

Click the tray icon to open the small native window. The title and footer show the
application version even before pairing or when the service is unavailable. Configured
status also shows the background agent version.

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
Ask your administrator to check the enrollment error and the platform deployment before
creating a fresh connector/code. Upgrading the tray alone does not repair a code whose
enrollment response was lost or rejected.

After the matching backend and portal update is deployed, administrators can delete an
unsuccessful setup from **Admin → Local Connectors** when it has never sent a heartbeat
(**Last seen** is empty). Paired status alone does not prevent deletion. Previously seen
connectors remain protected, including after a local Reset. Portal deletion invalidates
that identity and its pairing codes but preserves audit history; create a fresh
connector/code for the next pairing attempt. This requires no additional agent upgrade.

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

## Upgrade permission errors

If an older setup reports `icacls.exe failed: exit status 5` during an upgrade, use the
current standalone installer from [Downloads](DOWNLOADS.md), choosing the same architecture.
Accept Windows administrator approval. Setup repairs access to the connector's state
folder while preserving saved pairing and configuration; **Reset** is not required.

If repair cannot finish, setup identifies the failed operation and path and leaves the
service stopped. Share that error with your administrator. Linked or redirected state
folders are not supported by the repair.

## Local access and diagnostics

Pairing and status are available through the tray. Starting, stopping or resetting the
service requires Windows administrator approval. Pairing credentials are stored by
the background service and are not displayed in the tray.

For state and log locations, see [diagnostics and state](INSTALLATION.md#diagnostics-and-state).
Get the current installer from [Downloads](DOWNLOADS.md).
