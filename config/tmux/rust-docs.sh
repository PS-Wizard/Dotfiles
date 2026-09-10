#!/usr/bin/env bash

read -rp "Search Rust std docs: " query
[ -n "$query" ] || exit 0

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

zen-browser --new-tab "https://doc.rust-lang.org/std/?search=${query// /%20}" >/dev/null 2>&1
