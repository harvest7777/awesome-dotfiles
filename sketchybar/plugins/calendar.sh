#!/bin/bash

# Fills the clock popup with this month's calendar and highlights today.
# Sketchybar trims leading spaces, so each row's indent becomes padding.
# Today's highlight is the row item's background: the item is narrowed to
# one day cell and the background shifted under today's column, while the
# label keeps drawing past the item's width.

CHAR_W=8.4 # Hack Nerd Font Bold 14
CELL_W=25

px() { printf '%.0f' "$(echo "$1 * $CHAR_W" | bc)"; }

sketchybar --set cal.title label="$(date '+%B %Y')"

today=$(date +%-d)
first_dow=$(date -j -f %Y-%m-%d "$(date +%Y-%m-01)" +%w)
today_row=$(( (today + first_dow - 1) / 7 + 1 ))
today_col=$(( (today + first_dow - 1) % 7 ))

# Drop the title line, trailing whitespace and blank lines
rows=()
while IFS= read -r line; do
  rows+=("$line")
done < <(cal -h | tail -n +2 | sed -e 's/[[:space:]]*$//' -e '/^$/d')

for i in 0 1 2 3 4 5 6; do
  row="${rows[$i]}"
  if [ -z "$row" ]; then
    sketchybar --set cal.$i drawing=off
    continue
  fi

  text="${row#"${row%%[! ]*}"}"
  indent=$(px $(( ${#row} - ${#text} )))

  if [ "$i" -eq "$today_row" ]; then
    sketchybar --set cal.$i drawing=on label="$text" label.padding_left="$indent" \
      width=$CELL_W background.drawing=on \
      background.x_offset=$(( $(px $((today_col * 3))) - 4 ))
  else
    sketchybar --set cal.$i drawing=on label="$text" label.padding_left="$indent" \
      width=dynamic background.drawing=off
  fi
done

# Today's events from macOS Calendar (includes synced Google calendars)
MAX_EVENTS=6
events=()
while IFS= read -r line; do
  [ -n "$line" ] && events+=("$line")
done < <(/opt/homebrew/bin/icalBuddy -nc -nrd -ea -b '' -iep title,datetime \
  -po datetime,title -ps '|  |' -tf '%I:%M %p' -df '' eventsToday 2>/dev/null \
  | sed -E 's/(^| )0([0-9]:)/\1\2/g')

if [ ${#events[@]} -eq 0 ]; then
  events=("No events today")
fi

for ((i = 0; i < MAX_EVENTS; i++)); do
  if [ -n "${events[$i]}" ]; then
    sketchybar --set cal.event.$i drawing=on label="${events[$i]}"
  else
    sketchybar --set cal.event.$i drawing=off
  fi
done
