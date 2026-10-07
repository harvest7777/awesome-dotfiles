#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  # Look up the frontmost app directly; by name is ambiguous (e.g. Chrome's
  # notification helper is also called "Google Chrome")
  bundle_id=$(lsappinfo info -only bundleid "$(lsappinfo front)" | cut -d'"' -f4)
  sketchybar --set "$NAME" label="$INFO" icon.background.image="app.$bundle_id"
fi
