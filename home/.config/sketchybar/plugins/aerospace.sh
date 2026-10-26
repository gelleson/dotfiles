#!/bin/sh
# $1 workspace, $2 key color, $3 pressed color (from sketchybarrc's palette).
# Focused: pressed down, no skirt. Occupied: a normal key. Empty: hidden, so
# the row only shows where windows are. The legend is the workspace number
# then a Nerd Font glyph per app on it; Sunsama's Focus Bar follows every
# workspace, so it is left out.
icons=$(aerospace list-windows --workspace "$1" --format '%{app-bundle-id}|%{window-title}' \
  | grep -v '|Sunsama Focus Bar$' | cut -d'|' -f1 | sort -u | while read -r app; do
    case $app in
      (com.apple.Safari) echo '󰀹' ;;
      (company.thebrowser.Browser) echo '󰖟' ;;
      (com.google.Chrome) echo '󰊯' ;;
      (com.mitchellh.ghostty|dev.warp.Warp-Stable|net.kovidgoyal.kitty) echo '󰆍' ;;
      (dev.zed.Zed) echo '󰅩' ;;
      (dev.kdrag0n.MacVirt) echo '󰡨' ;;
      (ai.omnigent.desktop|com.openai.codex) echo '󰚩' ;;
      (com.apple.Music) echo '󰝚' ;;
      (com.apple.TV) echo '󰔂' ;;
      (com.sunsama.native-app) echo '󰃯' ;;
      (com.granola.app) echo '󰍬' ;;
      (com.apple.iCal) echo '󰃭' ;;
      (com.valvesoftware.steam.helper) echo '󰓓' ;;
      (games.mapc.app|com.blobfishgames|com.cdprojektred.cyberpunk.steam) echo '󰊗' ;;
      (md.obsidian) echo '󰠮' ;;
      (org.keepassxc.keepassxc) echo '󰌆' ;;
      (*) echo '󰣆' ;;
    esac
  done | awk '!seen[$0]++' | paste -sd' ' -)

if [ "$1" = "${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}" ]; then
  sketchybar --set "$NAME" drawing=on label="$1${icons:+ $icons}" y_offset=-2 background.shadow.drawing=off background.color=$3
elif [ -n "$icons" ]; then
  sketchybar --set "$NAME" drawing=on label="$1${icons:+ $icons}" y_offset=0 background.shadow.drawing=on background.color=$2
else
  sketchybar --set "$NAME" drawing=off
fi
