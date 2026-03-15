#!/usr/bin/env bash
# Daemon: records unseen notifications, clears app when its window is focused

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-notif-unseen"
WATCHED_APPS="$(dirname "$(realpath "$0")")/watched-apps.conf"

# --- D-Bus listener: capture app names from incoming notifications ---
dbus-monitor --session \
  "type='method_call',interface='org.freedesktop.Notifications',member='Notify'" \
  2>/dev/null |
awk '
  /member=Notify/ { capture=1; count=0 }
  capture && /string "/ {
    count++
    if (count == 1) {
      match($0, /string "([^"]*)"/, a)
      if (a[1] != "") { print a[1]; fflush() }
      capture=0
    }
  }
' | while read -r app_name; do
    # If watched-apps.conf exists and is non-empty, filter by it
    if [[ -s "$WATCHED_APPS" ]]; then
        grep -qxi "$app_name" "$WATCHED_APPS" || continue
    fi
    echo "$app_name" >> "$STATE_FILE"
done &

# --- Hyprland listener: remove app when its window becomes active ---
python3 - "$STATE_FILE" <<'EOF'
import socket, os, sys

state_file = sys.argv[1]
sig = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE', '')
rt  = os.environ.get('XDG_RUNTIME_DIR', '/tmp')
sock_path = f'{rt}/hypr/{sig}/.socket2.sock'

s = socket.socket(socket.AF_UNIX)
s.connect(sock_path)
buf = ''

while True:
    data = s.recv(4096).decode('utf-8', errors='ignore')
    buf += data
    while '\n' in buf:
        line, buf = buf.split('\n', 1)
        if not line.startswith('activewindow>>'):
            continue
        wclass = line[len('activewindow>>'):].split(',')[0].lower()
        if not os.path.exists(state_file):
            continue
        with open(state_file) as f:
            apps = f.read().splitlines()
        remaining = [a for a in apps if a.lower() != wclass]
        if remaining:
            with open(state_file, 'w') as f:
                f.write('\n'.join(remaining) + '\n')
        else:
            os.remove(state_file)
EOF
