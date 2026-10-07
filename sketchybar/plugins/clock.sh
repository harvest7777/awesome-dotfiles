#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

case "$SENDER" in
  mouse.clicked)
    # Only rebuild when opening; redrawing rows while closing makes it jump
    if [ "$(sketchybar --query "$NAME" | jq -r .popup.drawing)" = on ]; then
      sketchybar --set "$NAME" popup.drawing=off
    else
      "$CONFIG_DIR/plugins/calendar.sh"
      sketchybar --set "$NAME" popup.drawing=on
    fi
    ;;
  mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  *)
    sketchybar --set "$NAME" label="$(date '+%b %-d %-I:%M %p')"
    ;;
esac
