#!/bin/bash

# Shows the current Spotify track, grayed out when paused and hidden when
# Spotify stops. On spotify_change, $INFO holds the PlaybackStateChanged
# payload as JSON.

PLAYING_COLOR=0xfff5e6dc
PAUSED_COLOR=0x80f5e6dc
MAX_CHARS=28
export LC_ALL=en_US.UTF-8
SCROLL_PID="${TMPDIR:-/tmp}/sketchybar_spotify_scroll.pid"

# Stop any marquee left over from the previous track/state
if [ -f "$SCROLL_PID" ]; then
  kill "$(cat "$SCROLL_PID")" 2>/dev/null
  rm -f "$SCROLL_PID"
fi

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

label="$track – $artist"
sketchybar --set "$NAME" drawing=on label="$label" \
  label.width=dynamic label.padding_left=4 \
  icon.color=$color label.color=$color

# Scroll long titles while playing; paused ones just get cut off
if [ "$color" = "$PLAYING_COLOR" ] && [ ${#label} -gt $MAX_CHARS ]; then
  nohup "$CONFIG_DIR/plugins/spotify_scroll.sh" "$NAME" "$label" $MAX_CHARS \
    >/dev/null 2>&1 &
  echo $! > "$SCROLL_PID"
fi
