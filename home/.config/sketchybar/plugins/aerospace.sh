#!/bin/sh
# Presses the focused workspace's key down (grey cap, no skirt) and lets the
# rest spring back. Grey is LEGO light bluish grey; white is WHITE in sketchybarrc.
if [ "$1" = "${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}" ]; then
  sketchybar --set "$NAME" y_offset=-2 background.shadow.drawing=off background.color=0xffa0a5a9
else
  sketchybar --set "$NAME" y_offset=0 background.shadow.drawing=on background.color=0xfff2f2ee
fi
