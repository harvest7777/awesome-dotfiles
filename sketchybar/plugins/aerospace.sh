#!/bin/sh

# Shows the focused AeroSpace workspace. $FOCUSED_WORKSPACE comes from the
# aerospace_workspace_change event.

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

sketchybar --set "$NAME" icon="$FOCUSED"
