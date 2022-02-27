#!/usr/bin/env bash

script_dir=$(dirname $(realpath $0))
lock_script="$script_dir/awesome-lock.sh"
xidlehook \
	--timer 60 "$lock_script lock 1" "$lock_script unlock 1" \
	--timer 30 "$lock_script lock 2" "$lock_script unlock 2"
