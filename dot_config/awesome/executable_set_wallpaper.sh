#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

if [ -n "$1" ]; then
	awesome-client "for s in screen do require('gears').wallpaper.maximized('$SCRIPT_DIR/wallpapers/$1', s) end"
else
	cd "$SCRIPT_DIR" || exit
	cd ./wallpapers || exit

	ls -1
fi
