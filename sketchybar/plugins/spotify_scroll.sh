#!/bin/bash

# Scrolls $2 through item $1 as a looping marquee, $3 chars at a time.
# Started and killed by spotify.sh.
#
# Sketchybar trims leading whitespace, which would make the text jump, so
# leading spaces become extra left padding inside a fixed label width,
# keeping the item a constant width.

export LC_ALL=en_US.UTF-8

CHAR_W=9.6 # Hack Nerd Font Bold 16
PAD_LEFT=4

item="$1"
text="$2   •   "
width="$3"
loop="$text$text"

px() { printf '%.0f' "$(echo "$1 * $CHAR_W" | bc)"; }

i=0
while true; do
  window="${loop:i:width}"
  trimmed="${window#"${window%%[! ]*}"}"
  lead=$(( ${#window} - ${#trimmed} ))
  sketchybar --set "$item" label="$trimmed" \
    label.padding_left=$(( PAD_LEFT + $(px $lead) )) \
    label.width=$(px "$width")
  i=$(( (i + 1) % ${#text} ))
  sleep 0.3
done
