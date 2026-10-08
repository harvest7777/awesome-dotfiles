#!/usr/bin/env python3
"""Closes item $1's popup once the mouse leaves the item without going into
the popup. Started on the item's mouse.exited: sketchybar's
mouse.exited.global only fires after the mouse has been inside the popup.

The popup stays open while the mouse is back on the item, inside the popup,
or crossing the gap between them (for up to TIMEOUT seconds)."""

import json
import subprocess
import sys
import time

TIMEOUT = 2.0
POLL = 0.15
MARGIN = 6

item = sys.argv[1]


def query(name):
    out = subprocess.run(["sketchybar", "--query", name], capture_output=True, text=True).stdout
    return json.loads(out) if out.strip() else {}


def rect(info):
    r = info.get("bounding_rects", {}).get("display-1")
    if not r or info.get("geometry", {}).get("drawing") != "on":
        return None
    x, y = r["origin"]
    w, h = r["size"]
    return x, y, x + w, y + h


def mouse():
    # NSEvent reports from the bottom-left; sketchybar's rects are top-left
    out = subprocess.run(
        ["osascript", "-l", "JavaScript", "-e",
         'ObjC.import("AppKit"); var p = $.NSEvent.mouseLocation;'
         ' p.x + " " + ($.NSScreen.screens.objectAtIndex(0).frame.size.height - p.y)'],
        capture_output=True, text=True).stdout.split()
    return float(out[0]), float(out[1])


def inside(p, r, m=0):
    return r and r[0] - m <= p[0] <= r[2] + m and r[1] - m <= p[1] <= r[3] + m


def main():
    info = query(item)
    parent = rect(info)
    rows = [r for r in (rect(query(i)) for i in info.get("popup", {}).get("items", [])) if r]
    if not parent or not rows:
        return
    popup = (min(r[0] for r in rows), min(r[1] for r in rows),
             max(r[2] for r in rows), max(r[3] for r in rows))
    gap = (popup[0], parent[3], popup[2], popup[1])

    deadline = time.time() + TIMEOUT
    while time.time() < deadline:
        if query(item).get("popup", {}).get("drawing") != "on":
            return
        p = mouse()
        if inside(p, parent) or inside(p, popup, MARGIN):
            return
        if not inside(p, gap, MARGIN):
            break
        time.sleep(POLL)
    subprocess.run(["sketchybar", "--set", item, "popup.drawing=off"])


main()
