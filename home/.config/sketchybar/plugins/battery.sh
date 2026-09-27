#!/bin/sh
BATT=$(pmset -g batt)
PCT=$(echo "$BATT" | grep -Eo '[0-9]+%' | tr -d %)
case $PCT in
  100|9?) ICON=󰁹 ;;
  [6-8]?) ICON=󰂁 ;;
  [3-5]?) ICON=󰁾 ;;
  [1-2]?) ICON=󰁻 ;;
  *)      ICON=󰂎 ;;
esac
case $BATT in *"AC Power"*) ICON=󰂄 ;; esac
sketchybar --set "$NAME" icon="$ICON" label="$PCT%"
