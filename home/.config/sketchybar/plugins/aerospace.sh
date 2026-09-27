#!/bin/sh
# Focused workspace: grey key pressed down. Occupied: white key. Empty: hidden,
# so the row only shows where windows are. Grey is LEGO light bluish grey;
# white is WHITE in sketchybarrc.
if [ "$1" = "${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}" ]; then
  sketchybar --set "$NAME" drawing=on y_offset=-2 background.shadow.drawing=off background.color=0xffa0a5a9
elif [ "$(aerospace list-windows --workspace "$1" --count)" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on y_offset=0 background.shadow.drawing=on background.color=0xfff2f2ee
else
  sketchybar --set "$NAME" drawing=off
fi
