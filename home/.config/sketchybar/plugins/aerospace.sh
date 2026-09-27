#!/bin/sh
# $1 workspace, $2 key color, $3 pressed color (from sketchybarrc's palette).
# Focused: pressed down, no skirt. Occupied: a normal key. Empty: hidden, so
# the row only shows where windows are.
if [ "$1" = "${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}" ]; then
  sketchybar --set "$NAME" drawing=on y_offset=-2 background.shadow.drawing=off background.color=$3
elif [ "$(aerospace list-windows --workspace "$1" --count)" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on y_offset=0 background.shadow.drawing=on background.color=$2
else
  sketchybar --set "$NAME" drawing=off
fi
