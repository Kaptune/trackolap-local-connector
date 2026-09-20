#!/bin/sh
#
# .deb / .rpm postremove - clean up after a real removal.
#
# The distinction that matters: REMOVE leaves the state directory alone (it holds the
# enrollment, and an operator who removes to reinstall expects the machine to still be
# paired), PURGE deletes it.
#
#   deb: $1 = remove | purge | upgrade | ...
#   rpm: $1 = 0 (erase) | 1 (upgrade). rpm has no purge concept, so an erase keeps state.
set -e

USER_NAME=trackolap-connector
GROUP_NAME=trackolap-connector
STATE_DIR=/var/lib/trackolap-connector

if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
    systemctl daemon-reload >/dev/null 2>&1 || true
    systemctl reset-failed tlp-connector.service >/dev/null 2>&1 || true
fi

case "${1:-}" in
    purge)
        # Deliberate and destructive: this deletes the agent's identity (agentId, HMAC
        # secret, watermarks). Re-installing after a purge needs a NEW pairing code -
        # the old agent record must be revoked in the portal.
        echo "tlp-connector: purging ${STATE_DIR} (agent identity and sync state)"
        rm -rf "$STATE_DIR"

        if getent passwd "$USER_NAME" >/dev/null 2>&1; then
            if command -v userdel >/dev/null 2>&1; then
                userdel "$USER_NAME" >/dev/null 2>&1 || true
            else
                deluser --system "$USER_NAME" >/dev/null 2>&1 || true
            fi
        fi
        if getent group "$GROUP_NAME" >/dev/null 2>&1; then
            if command -v groupdel >/dev/null 2>&1; then
                groupdel "$GROUP_NAME" >/dev/null 2>&1 || true
            else
                delgroup --system "$GROUP_NAME" >/dev/null 2>&1 || true
            fi
        fi
        ;;
    remove|0)
        echo "tlp-connector: removed. ${STATE_DIR} kept (enrollment preserved)."
        echo "tlp-connector: to erase it too:  sudo apt-get purge tlp-connector"
        echo "tlp-connector:                   or: sudo rm -rf ${STATE_DIR}"
        ;;
esac

exit 0
