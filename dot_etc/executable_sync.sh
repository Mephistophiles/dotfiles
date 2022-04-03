#!/usr/bin/env bash

rsync -av \
	--exclude="hardware-configuration.nix" \
	--exclude="host.nix" \
	--exclude=".git" \
	--delete \
	/etc/nixos \
	/home/mzhukov/.etc/
