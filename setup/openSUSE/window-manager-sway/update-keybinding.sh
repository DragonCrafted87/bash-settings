#!/bin/bash

# Append keybinding to Sway config
cat <<'EOF' >> ~/.config/sway/config
set $mod Mod4
bindsym $mod+Space exec "selected=$(wofi --show run --prompt='Context Menu' --lines=10 --width=300 --height=400 --cache-file=/dev/null --allow-images=false --allow-markup=false --define=hide_search=true --define=insensitive=true --command='bash -c \"~/window-manager-sway/sway-context-menu.sh\"'); case $selected in 'Brave') brave-browser;; 'Terminal') alacritty;; 'Close Sway') swaymsg exit;; *) [ -n \"$selected\" ] && swaymsg [title=\"$selected\"] focus;; esac"
EOF

echo "Keybinding updated. Please restart Sway for the changes to take effect."
