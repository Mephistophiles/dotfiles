#!/usr/bin/env bash

if redminer timer status date today active | grep -q "Running"; then
	redminer timer suspend
elif redminer timer status date today active | grep -q "Suspended"; then
	redminer timer resume
fi
