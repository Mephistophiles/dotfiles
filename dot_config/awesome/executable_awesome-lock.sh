#!/usr/bin/env fish

set SCRIPT_DIR (realpath (dirname (status --current-filename)))

function screen_lock
	# Lock screen displaing this image
	i3lock -c 000000
end

function lock
	set -l phase "$argv[1]"

	switch $phase
		case 1
			pkill -f awesome-dimm.sh
			$SCRIPT_DIR/awesome-dimm.sh off
		case 2
			screen_lock
	end
end

function unlock
	set -l phase "$argv[1]"

	switch $phase
		case 1
			pkill -f awesome-dimm.sh
			$SCRIPT_DIR/awesome-dimm.sh on
		case 2
			pkill -f awesome-dimm.sh
			$SCRIPT_DIR/awesome-dimm.sh on
	end
end


switch "$argv[1]"
	case lock
		lock "$argv[2]"
	case unlock
		unlock "$argv[2]"
end
