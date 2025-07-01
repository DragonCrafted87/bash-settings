#!/bin/bash

# Determine the directory of this script
SCRIPT_DIR=$(dirname "$0")

# Update package list
sudo zypper refresh

# Install necessary packages
sudo zypper install -y curl

# Add Brave repository and import key
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

# Install sway, audio, and other dependencies
sudo zypper install -y sway sway-branding-upstream wofi jq mpv python3-pip brave-browser pipewire pipewire-pulseaudio pipewire-alsa pavucontrol

# Install jellyfin-mpv-shim
sudo pip3 install --upgrade jellyfin-mpv-shim

# Enable PipeWire user services for audio
systemctl --user enable pipewire.service pipewire-pulse.service
systemctl --user start pipewire.service pipewire-pulse.service

# Set up Sway configuration
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/config

# Add autostart for jellyfin-mpv-shim
echo "exec jellyfin-mpv-shim" >> ~/.config/sway/config

# Ensure auxiliary scripts are executable
chmod +x "$SCRIPT_DIR"/window-manager-sway/*.sh

# Run the auxiliary scripts
"$SCRIPT_DIR"/window-manager-sway/update-keybinding.sh

# Check if Sway is running and restart it if necessary
if swaymsg -t get_version > /dev/null 2>&1; then
    echo "Restarting Sway by exiting current session..."
    swaymsg exit  # This exits Sway, allowing the user to log back in
else
    echo "Sway is not running. Start Sway to apply the new configuration."
fi
