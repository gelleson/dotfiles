#!/bin/sh
CPU=$(ps -A -o %cpu= | awk -v n="$(sysctl -n hw.ncpu)" '{s+=$1} END {printf "%d", s/n}')
MEM=$(memory_pressure | awk '/free percentage/ {print 100 - $5}')
sketchybar --set "$NAME" label="󰻠 $CPU%  󰍛 $MEM%"
