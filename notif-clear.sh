#!/usr/bin/env bash
# Clear unseen notifications state

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-notif-unseen"
rm -f "$STATE_FILE"
