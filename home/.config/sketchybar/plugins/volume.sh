#!/bin/sh
# volume_change passes the level in $INFO; the startup run has to ask.
VOL=${INFO:-$(osascript -e 'output volume of (get volume settings)')}
case $VOL in
  0)                ICON=󰖁 ;;
  [0-9]|[1-2][0-9]) ICON=󰕿 ;;
  [3-6][0-9])       ICON=󰖀 ;;
  *)                ICON=󰕾 ;;
esac
sketchybar --set "$NAME" icon="$ICON"
