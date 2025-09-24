#!/bin/bash

# Terminate any already running Waybar instances
killall -q waybar
sleep 0.2

# Launch Waybar using the direct command that is known to work
waybar -c ~/.config/waybar/themes/dreamy/config -s ~/.config/waybar/themes/dreamy/style.css &