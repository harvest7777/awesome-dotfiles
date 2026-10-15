#!/bin/bash

# Shows a directory in Finder on the current workspace, e.g.
# `finder-here.sh ~/Downloads`. If a Finder window is already on this
# workspace it gets the directory as a new tab and focus; otherwise a new
# window opens here. Finder windows on other workspaces are never touched,
# unlike `open`, which reuses one wherever it is and switches workspace to it.
#
# Tabbing relies on AppleWindowTabbingMode=always: a window Finder makes while
# it's frontmost joins the focused window as a tab, and one it makes in the
# background stands alone.

export PATH="/opt/homebrew/bin:$PATH"

dir=$(cd -- "${1:-.}" && pwd) || exit 1

finder_windows() {
  aerospace list-windows --workspace focused --app-bundle-id com.apple.finder \
    --format '%{window-id}'
}

new_window() {
  osascript - "$dir" <<'EOF' >/dev/null
on run argv
  tell application "Finder" to make new Finder window to (POSIX file (item 1 of argv))
end run
EOF
}

focused=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
here=$(finder_windows)

if [ -n "$here" ]; then
  # Prefer the Finder window already in focus, else any on this workspace
  if grep -qx "$focused" <<<"$here"; then
    target=$focused
  else
    target=$(head -1 <<<"$here")
    aerospace focus --window-id "$target"
    # Finder has to be frontmost before the window is made, or it won't tab
    for _ in $(seq 20); do
      [ "$(aerospace list-windows --focused --format '%{window-id}')" = "$target" ] && break
      sleep 0.05
    done
  fi
  new_window
  exit
fi

# Finder cascades a new window off its last one, which can be parked in
# AeroSpace's hidden corner, so center it on the screen instead
osascript - "$dir" <<'EOF' >/dev/null
on run argv
  tell application "Finder"
    set w to make new Finder window to (POSIX file (item 1 of argv))
    set {wl, wt, wr, wb} to bounds of w
    set {dl, dt, dr, db} to bounds of window of desktop
    set x to (dr - dl - (wr - wl)) div 2
    set y to (db - dt - (wb - wt)) div 2
    set bounds of w to {x, y, x + wr - wl, y + wb - wt}
  end tell
end run
EOF
# Wait for AeroSpace to see the new window, then focus it
for _ in $(seq 20); do
  id=$(finder_windows | head -1)
  [ -n "$id" ] && break
  sleep 0.1
done
[ -n "$id" ] && aerospace focus --window-id "$id"
