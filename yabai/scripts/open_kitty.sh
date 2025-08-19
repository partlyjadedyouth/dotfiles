#!/usr/bin/env bash

# Detects if kitty is running
if ! pgrep -f "kitty" > /dev/null 2>&1; then
    open -a "/Applications/kitty.app"
fi
