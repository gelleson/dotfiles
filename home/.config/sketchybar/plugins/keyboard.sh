#!/bin/sh
# Prints which keyboard is connected: node (Node75, wins if both), kick
# (Kick75), or builtin (neither). Given the one the bar was loaded for,
# reloads it if that changed. hidutil lists connected devices only, Bluetooth
# included.
HID=$(hidutil list)
case $HID in
  *"Node 75"*) KB=node ;;
  *Kick75*)    KB=kick ;;
  *)           KB=builtin ;;
esac
if [ -z "$1" ]; then
  echo $KB
elif [ "$1" != "$KB" ]; then
  sketchybar --reload
fi
