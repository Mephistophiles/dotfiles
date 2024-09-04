#!/usr/bin/env bash
export LC_ALL=C

enable_disable_wifi ()
{
	result=$(nmcli dev | grep "ethernet" | grep -w "connected")
	if [ -n "$result" ]; then
		nmcli radio wifi off
	else
		nmcli radio wifi on
	fi
}

case "$2" in
	up|down)  enable_disable_wifi ;;
esac
