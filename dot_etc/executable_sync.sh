#!/usr/bin/env bash

rsync -av \
	--exclude="hardware-configuration.nix" \
	--exclude="host.nix" \
	--exclude=".git" \
	/etc/nixos \
	/home/mzhukov/.etc/
