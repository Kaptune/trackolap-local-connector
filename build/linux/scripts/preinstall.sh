#!/bin/sh
#
# .deb / .rpm preinstall - create the unprivileged system account the service runs as.
#
# Runs BEFORE the payload lands so the packaged /var/lib/trackolap-connector directory can
# be chowned to an account that already exists. Doing it in postinstall means the directory
# is created owned by root and the service cannot write its own state.
set -e

USER_NAME=trackolap-connector
GROUP_NAME=trackolap-connector
HOME_DIR=/var/lib/trackolap-connector

# A SYSTEM account (--system): no login shell, no password, no /home, and a UID below 1000
# so it never shows up on the login screen. The agent needs to read a local TCP port and
# write one directory; it needs nothing else, and it must never be a usable login.
if ! getent group "$GROUP_NAME" >/dev/null 2>&1; then
    if command -v groupadd >/dev/null 2>&1; then
        groupadd --system "$GROUP_NAME"
    else
        addgroup --system "$GROUP_NAME"
    fi
fi

if ! getent passwd "$USER_NAME" >/dev/null 2>&1; then
    if command -v useradd >/dev/null 2>&1; then
        useradd --system --gid "$GROUP_NAME" --home-dir "$HOME_DIR" \
                --no-create-home --shell /usr/sbin/nologin \
                --comment "TrackOlap Connector service account" "$USER_NAME"
    else
        adduser --system --ingroup "$GROUP_NAME" --home "$HOME_DIR" \
                --no-create-home --disabled-login --shell /usr/sbin/nologin \
                --gecos "TrackOlap Connector service account" "$USER_NAME"
    fi
fi

exit 0
