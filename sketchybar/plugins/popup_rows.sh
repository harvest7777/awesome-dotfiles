#!/bin/bash

# Shared styling for the popups, sourced by sketchybarrc and the plugins.
# popup.height is kept small so pad rows stay thin; every other row gets its
# height from a transparent background.

popup_item=(
  icon.drawing=off
  label.font="Hack Nerd Font:Bold:14.0"
  background.drawing=on
  background.color=0x00000000
  background.height=24
  padding_left=10
  padding_right=10
)
popup_pad=(icon.drawing=off label.drawing=off)

# popup_rows PARENT PREFIX PAD ROW...
# Replaces PARENT's PREFIX.N rows with one row per ROW, then re-adds the PAD
# row after them. New popup items always go at the end, so the bottom pad
# has to be recreated to stay last.
popup_rows() {
  local parent=$1 prefix=$2 pad=$3 i=0
  shift 3

  sketchybar --remove "/${prefix//./\\.}\\..*/" --remove "$pad" >/dev/null 2>&1

  local args=()
  for row in "$@"; do
    args+=(--add item "$prefix.$i" "popup.$parent"
           --set "$prefix.$i" "${popup_item[@]}" label="$row")
    i=$((i + 1))
  done
  sketchybar "${args[@]}" --add item "$pad" "popup.$parent" --set "$pad" "${popup_pad[@]}"
}
