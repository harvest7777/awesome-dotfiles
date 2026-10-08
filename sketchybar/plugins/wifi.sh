#!/bin/sh

# Shows the Wi-Fi network name, or an off/disconnected icon. The SSID is only
# visible after `sudo ipconfig setverbose 1`; otherwise macOS redacts it.

if [ "$(networksetup -getairportpower en0 | awk '{print $NF}')" != "On" ]; then
  sketchybar --set "$NAME" icon=󰖪 label.drawing=off
  exit 0
fi

ssid=$(ipconfig getsummary en0 | awk -F ' SSID : ' '/ SSID : / { print $2 }')

if [ -n "$ssid" ]; then
  sketchybar --set "$NAME" icon=󰖩 label="$ssid" label.drawing=on
else
  sketchybar --set "$NAME" icon=󰤮 label.drawing=off
fi
