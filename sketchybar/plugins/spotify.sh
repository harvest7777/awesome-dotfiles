#!/bin/bash

# Shows the current Spotify track, grayed out when paused and hidden when
# Spotify stops. On spotify_change, $INFO holds the PlaybackStateChanged
# payload as JSON.

PLAYING_COLOR=0xfff5e6dc
PAUSED_COLOR=0x80f5e6dc

if [ "$SENDER" = "spotify_change" ]; then
  state=$(echo "$INFO" | jq -r '."Player State"')
  track=$(echo "$INFO" | jq -r '.Name')
  artist=$(echo "$INFO" | jq -r '.Artist')
elif pgrep -xq Spotify; then
  # On startup/reload there's no event yet, so ask Spotify directly
  IFS=$'\t' read -r state track artist < <(osascript -e '
    tell application "Spotify" to return (player state as string) & tab & (name of current track) & tab & (artist of current track)')
else
  state=stopped
fi

case "$(echo "$state" | tr '[:upper:]' '[:lower:]')" in
  playing) color=$PLAYING_COLOR ;;
  paused) color=$PAUSED_COLOR ;;
  *)
    sketchybar --set "$NAME" drawing=off
    exit 0
    ;;
esac

sketchybar --set "$NAME" drawing=on label="$track – $artist" \
  icon.color=$color label.color=$color
