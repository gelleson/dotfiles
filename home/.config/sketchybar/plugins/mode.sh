#!/bin/sh
# $1 esc cap, $2 esc skirt, $3 esc legend, $4 knob cap, $5 knob legend.
# HyprMac removes state.json while tiling is paused (Hypr+P) or it isn't
# running, so the esc key is held down in the knob's color and reads "pause".
if [ ! -e "$HOME/Library/Application Support/HyprMac/state.json" ]; then
  sketchybar --set "$NAME" label=pause y_offset=-2 icon.color=$5 label.color=$5 \
    background.color=$4 background.shadow.drawing=off
else
  sketchybar --set "$NAME" label=esc y_offset=0 icon.color=$3 label.color=$3 \
    background.color=$1 background.shadow.drawing=on background.shadow.color=$2
fi
