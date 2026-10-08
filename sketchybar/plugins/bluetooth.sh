#!/bin/sh

# Shows whether Bluetooth is on and the names of connected devices.

BLUEUTIL=/opt/homebrew/bin/blueutil

if [ "$($BLUEUTIL --power)" != "1" ]; then
  sketchybar --set "$NAME" icon=󰂲 label.drawing=off
  exit 0
fi

devices=$($BLUEUTIL --connected --format json | jq -r '[.[].name] | join(", ")')

if [ -n "$devices" ]; then
  sketchybar --set "$NAME" icon=󰂱 label="$devices" label.drawing=on
else
  sketchybar --set "$NAME" icon=󰂯 label.drawing=off
fi
