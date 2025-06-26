#!/bin/bash

# Static menu items
echo "Brave"
echo "Terminal"
echo "Close Sway"
echo "---"  # Divider
# Dynamically list running applications
swaymsg -t get_tree | jq -r '.nodes[].nodes[].nodes[] | select(.type=="con") | .name' | grep -v '^null$'
