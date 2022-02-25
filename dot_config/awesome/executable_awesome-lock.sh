#!/usr/bin/env fish

function screen_lock
	# Lock screen displaing this image
	slock
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
