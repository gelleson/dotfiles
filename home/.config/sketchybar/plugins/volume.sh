#!/bin/sh
# volume_change only carries the level, so ask for mute as well.
SETTINGS=$(osascript -e 'get volume settings')
VOL=$(echo "$SETTINGS" | sed -E 's/.*output volume:([0-9]+).*/\1/')
case $SETTINGS in *"output muted:true"*) VOL=0 ;; esac
case $VOL in
  0)                ICON=󰖁 ;;
  [0-9]|[1-2][0-9]) ICON=󰕿 ;;
  [3-6][0-9])       ICON=󰖀 ;;
  *)                ICON=󰕾 ;;
esac
sketchybar --set "$NAME" icon="$ICON"
