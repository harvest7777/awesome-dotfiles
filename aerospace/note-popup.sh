#!/bin/bash

# Toggles a floating Ghostty window editing ~/Documents/scratch/$1.md, e.g.
# `note-popup.sh todo`. Each pop-up is its own Ghostty instance, found by its
# pid. Hiding parks it on an unbound "hidden" workspace; showing pulls it onto
# the current one.

export PATH="/opt/homebrew/bin:$PATH"

NOTE="/Users/ryantran/Documents/scratch/$1.md"
# The pop-up's Ghostty is the only one launched with this, so it doubles as
# the marker for finding its process
MARK="--initial-command=/opt/homebrew/bin/nvim $NOTE"

window_id() {
  local pid
  pid=$(pgrep -f -- "$MARK" | head -1)
  [ -n "$pid" ] && aerospace list-windows --all --format '%{window-id}|%{app-pid}' |
    awk -F'|' -v p="$pid" '$2 == p { print $1; exit }'
}

if ! pgrep -qf -- "$MARK"; then
  # Not -e: launched through `open`, Ghostty treats a trailing path as a
  # document to run in a shell instead of an argument to nvim
  open -na Ghostty --args --window-save-state=never \
    --quit-after-last-window-closed=true \
    --window-width=64 --window-height=21 "$MARK"
  for _ in $(seq 20); do
    id=$(window_id) && [ -n "$id" ] && break
    sleep 0.1
  done
  [ -n "$id" ] && aerospace layout --window-id "$id" floating
  exit
fi

id=$(window_id)
[ -z "$id" ] && exit

if [ "$id" = "$(aerospace list-windows --focused --format '%{window-id}')" ]; then
  aerospace move-node-to-workspace --window-id "$id" hidden
else
  aerospace move-node-to-workspace --window-id "$id" "$(aerospace list-workspaces --focused)"
  aerospace focus --window-id "$id"
fi
