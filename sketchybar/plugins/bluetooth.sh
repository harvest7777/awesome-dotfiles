#!/bin/bash

# Shows whether Bluetooth is on and how many devices are connected. Clicking
# opens a popup listing the connected devices.

BLUEUTIL=/opt/homebrew/bin/blueutil
MAX_DEVICES=8

devices=()
if [ "$($BLUEUTIL --power)" = "1" ]; then
  power=on
  while IFS= read -r name; do
    [ -n "$name" ] && devices+=("$name")
  done < <($BLUEUTIL --connected --format json | jq -r '.[].name')
fi

case "$SENDER" in
  mouse.clicked)
    # Only rebuild when opening, like the calendar
    if [ "$(sketchybar --query "$NAME" | jq -r .popup.drawing)" = on ]; then
      sketchybar --set "$NAME" popup.drawing=off
      exit 0
    fi

    rows=("${devices[@]}")
    if [ "$power" != on ]; then
      rows=("Bluetooth is off")
    elif [ ${#rows[@]} -eq 0 ]; then
      rows=("No devices connected")
    fi

    for ((i = 0; i < MAX_DEVICES; i++)); do
      if [ -n "${rows[$i]}" ]; then
        sketchybar --set bt.device.$i drawing=on label="${rows[$i]}"
      else
        sketchybar --set bt.device.$i drawing=off
      fi
    done
    sketchybar --set "$NAME" popup.drawing=on
    ;;
  mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  *)
    if [ "$power" != on ]; then
      sketchybar --set "$NAME" icon=󰂲 label.drawing=off
    elif [ ${#devices[@]} -gt 0 ]; then
      sketchybar --set "$NAME" icon=󰂱 label="(${#devices[@]})" label.drawing=on
    else
      sketchybar --set "$NAME" icon=󰂯 label.drawing=off
    fi
    ;;
esac
