#!/bin/sh
# $1 esc cap, $2 esc skirt, $3 esc legend, $4 knob cap, $5 knob legend.
# AeroSpace's game mode (workspace 5) passes every alt chord to the game, so
# the esc key is held down in the knob's color and reads "game" meanwhile.
if [ "$(aerospace list-modes --current)" = game ]; then
  sketchybar --set "$NAME" label=game y_offset=-2 icon.color=$5 label.color=$5 \
    background.color=$4 background.shadow.drawing=off
else
  sketchybar --set "$NAME" label=esc y_offset=0 icon.color=$3 label.color=$3 \
    background.color=$1 background.shadow.drawing=on background.shadow.color=$2
fi
