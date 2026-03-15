#!/usr/bin/env bash
# Output unique app names from unseen notifications state file

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-notif-unseen"

[[ -f "$STATE_FILE" ]] || exit 0

sort -u "$STATE_FILE" | tr '\n' ' ' | sed 's/ $/\n/'
