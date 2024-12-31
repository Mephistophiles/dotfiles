#!/usr/bin/env fish

set DISPLAYS (xrandr | grep -w connected | awk '{ print $1 }')

function set_brightness
	for display in $DISPLAYS
		xrandr --output $display --brightness $argv[1]
	end
end

set_brightness 1
xset dpms force on &>/dev/null

if string match -a "off" $argv[1]
	for brightness in (seq 1 -0.01 0.1)
		set_brightness $brightness
		sleep 0.05
	end
	xset dpms force off &>/dev/null
end
