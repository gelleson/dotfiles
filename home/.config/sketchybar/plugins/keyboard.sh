#!/bin/sh
# Prints which NuPhy is connected: node for the Node75, else kick (Kick75, or
# neither). Given the one the bar was loaded for, reloads it if that changed.
# hidutil lists connected devices only, Bluetooth included.
KB=kick
hidutil list | grep -q "Node 75" && KB=node
if [ -z "$1" ]; then
  echo $KB
elif [ "$1" != "$KB" ]; then
  sketchybar --reload
fi
