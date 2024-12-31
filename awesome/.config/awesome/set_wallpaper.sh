#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
WALLPAPERS_DIR="$SCRIPT_DIR/wallpapers"

list_wallpapers() {
	cd "$WALLPAPERS_DIR" || exit

	ls -1
}

WALLPAPPER=$(list_wallpapers | rofi -dmenu)

if [ -f "$WALLPAPERS_DIR/$WALLPAPPER" ]; then
	awesome-client "for s in screen do require('gears').wallpaper.maximized('$WALLPAPERS_DIR/$WALLPAPPER', s) end"
fi
