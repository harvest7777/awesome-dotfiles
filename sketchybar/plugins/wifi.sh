#!/bin/sh

# Shows a Wi-Fi icon for connected, disconnected or off. No network name.

if [ "$(networksetup -getairportpower en0 | awk '{print $NF}')" != "On" ]; then
  sketchybar --set "$NAME" icon=󰖪 label.drawing=off
elif ipconfig getifaddr en0 >/dev/null; then
  sketchybar --set "$NAME" icon=󰖩 label.drawing=off
else
  sketchybar --set "$NAME" icon=󰤮 label.drawing=off
fi
