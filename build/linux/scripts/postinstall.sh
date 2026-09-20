#!/bin/sh
#
# .deb / .rpm postinstall - enable and start the service, and re-assert the state
# directory's ownership.
#
# Handles both a first install and an upgrade. On an upgrade the service is already
# running: `restart` picks up the new binary, whereas `start` would be a no-op and leave
# the OLD code running - a fix that is installed but not live.
set -e

USER_NAME=trackolap-connector
STATE_DIR=/var/lib/trackolap-connector
SERVICE=tlp-connector.service

# The packaged directory carries the right mode/owner, but an upgrade over an install that
# predates the system account (or an rpm built without owner mapping) can leave it root-owned.
if [ -d "$STATE_DIR" ]; then
    chown -R "$USER_NAME":"$USER_NAME" "$STATE_DIR" 2>/dev/null || true
    chmod 700 "$STATE_DIR" 2>/dev/null || true
fi

# No systemd (a container, or a WSL/sysvinit box): install the files and stop. Failing here
# would abort a package install that is otherwise perfectly good.
if ! command -v systemctl >/dev/null 2>&1 || [ ! -d /run/systemd/system ]; then
    echo "tlp-connector: systemd not detected; the binary is installed at /usr/bin/tlp-connector."
    echo "tlp-connector: start it yourself with: tlp-connector -service"
    exit 0
fi

systemctl daemon-reload >/dev/null 2>&1 || true

if systemctl is-active --quiet "$SERVICE" 2>/dev/null; then
    echo "tlp-connector: restarting to pick up the new binary"
    systemctl restart "$SERVICE" || true
else
    systemctl enable "$SERVICE" >/dev/null 2>&1 || true
    systemctl start "$SERVICE" || true
fi

# Unattended enrollment: TLP_PAIRCODE=... apt-get install ./tlp-connector.deb
if [ -n "${TLP_PAIRCODE:-}" ]; then
    echo "tlp-connector: staging the supplied pairing code"
    # -pair prints the file path, never the code itself - dpkg output is not private.
    if [ -n "${TLP_SERVER:-}" ]; then
        /usr/bin/tlp-connector -pair "$TLP_PAIRCODE" -server "$TLP_SERVER"
    else
        /usr/bin/tlp-connector -pair "$TLP_PAIRCODE"
    fi
    chown "$USER_NAME":"$USER_NAME" "$STATE_DIR/pairing.json" 2>/dev/null || true
    systemctl restart "$SERVICE" || true
fi

cat <<'MSG'
tlp-connector installed.
  pair:      sudo tlp-connector -pair <pairing-code>
  diagnose:  sudo -u trackolap-connector tlp-connector -doctor
  logs:      journalctl -u tlp-connector -f
MSG
exit 0
