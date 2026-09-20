#!/bin/sh
#
# .deb / .rpm preremove - stop the service before its binary disappears.
#
# $1 distinguishes removal from upgrade:
#   deb: "remove" | "upgrade"
#   rpm: "0" (last version being erased) | "1" (upgrade)
# On an UPGRADE we must NOT disable the unit, or the service comes back disabled and never
# starts again after a routine `apt upgrade`.
set -e

SERVICE=tlp-connector.service

is_upgrade() {
    case "${1:-}" in
        upgrade|1) return 0 ;;
        *) return 1 ;;
    esac
}

if ! command -v systemctl >/dev/null 2>&1 || [ ! -d /run/systemd/system ]; then
    exit 0
fi

systemctl stop "$SERVICE" >/dev/null 2>&1 || true

if ! is_upgrade "${1:-}"; then
    systemctl disable "$SERVICE" >/dev/null 2>&1 || true
fi

exit 0
