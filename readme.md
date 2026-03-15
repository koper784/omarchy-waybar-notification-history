Sometimes I missed a notification in Omarchy and then I had no idea someone texted me. So this is some script created by claude.

In watched-apps.conf you add app names that you want to see the notifications of. If you leave it empty, every app is tracked.

Additional config:
Config files modified:

~/.config/waybar/config.jsonc:

Added "custom/notifications" to modules-right:
"modules-right": [
    "custom/notifications",
    ...
    ...
  ],

Added the custom/notifications module definition (exec, interval, format, on-click):
 "custom/notifications": {
    "exec": "~/Projects/Waybar-notif/notif.sh",
    "interval": 3,
    "format": "󰂚 {}",
    "on-click": "~/Projects/Waybar-notif/notif-clear.sh",
    "tooltip": false
  },

~/.config/hypr/autostart.conf:

Added exec-once = ~/Projects/Waybar-notif/notif-daemon.sh to start the daemon on login

prolly put those .sh and .conf inside config directory and change paths.