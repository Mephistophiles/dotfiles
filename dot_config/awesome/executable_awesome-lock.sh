#!/usr/bin/env fish

function screen_lock
	if pidof i3lock >/dev/null 2>&1
		return
	end

	pkill i3lock

	# Lock screen displaing this image
	i3lock -f -c 000000
end

function lock
	set -l phase "$argv[1]"

	switch $phase
		case 1
			xset dpms force off
		case 2
			screen_lock
	end
end

function unlock
	set -l phase "$argv[1]"

	switch $phase
		case 1
			xset dpms force on
		case 2
	end
end


switch "$argv[1]"
	case lock
		lock "$argv[2]"
	case unlock
		unlock "$argv[2]"
end
