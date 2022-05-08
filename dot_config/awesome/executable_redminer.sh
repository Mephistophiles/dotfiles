#!/usr/bin/env bash

export PATH="$PATH:$HOME/bin"
SCRIPT_DIR=$(dirname $(realpath $0))
lua $SCRIPT_DIR/redminer.lua
