#!/bin/bash

# Toggles a floating Ghostty window editing the todo list. The pop-up is its
# own Ghostty instance, found by its pid. Hiding parks it on an unbound
# "scratch" workspace; showing pulls it onto the current one.

export PATH="/opt/homebrew/bin:$PATH"

TODO=/Users/ryantran/Documents/scratch/todo.md
MARK=--title=todo-popup

window_id() {
  local pid
  pid=$(pgrep -f -- "$MARK" | head -1)
  [ -n "$pid" ] && aerospace list-windows --all --format '%{window-id}|%{app-pid}' |
    awk -F'|' -v p="$pid" '$2 == p { print $1; exit }'
}

if ! pgrep -qf -- "$MARK"; then
  # Not -e: launched through `open`, Ghostty treats a trailing path as a
  # document to run in a shell instead of an argument to nvim
  open -na Ghostty --args "$MARK" --window-save-state=never \
    --quit-after-last-window-closed=true \
    --window-width=64 --window-height=21 \
    "--initial-command=/opt/homebrew/bin/nvim $TODO"
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
  aerospace move-node-to-workspace --window-id "$id" scratch
else
  aerospace move-node-to-workspace --window-id "$id" "$(aerospace list-workspaces --focused)"
  aerospace focus --window-id "$id"
fi
