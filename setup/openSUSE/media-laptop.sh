#!/bin/bash

# Combined check for root privileges and SUDO_USER
if [ "$EUID" -ne 0 ] || [ -z "$SUDO_USER" ]; then
  echo "This script must be run with sudo from a regular user."
  exit 1
fi

# Get the user's home directory
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

# Install Sway and basic utilities
zypper install -y sway-branding-openSUSE alacritty wofi waybar grim light networkmanager-applet

# Create the Sway configuration directory if it doesn't exist
if [ ! -d "$USER_HOME/.config/sway" ]; then
  sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/.config/sway"
fi

# Check if the configuration file already exists
if [ ! -f "$USER_HOME/.config/sway/config" ]; then
  if [ -f "/etc/sway/config" ]; then
    # Copy the default configuration
    sudo -u "$SUDO_USER" cp /etc/sway/config "$USER_HOME/.config/sway/config"
  else
    # Create a basic configuration file
    echo "Default Sway configuration not found. Creating a basic configuration."
    sudo -u "$SUDO_USER" bash -c "cat << EOF > '$USER_HOME/.config/sway/config'
# Basic Sway configuration
set \$mod Mod4
bindsym \$mod+Return exec alacritty
bindsym \$mod+d exec wofi --show run
bar {
  status_command waybar
}
EOF"
  fi
else
  echo "Sway configuration file already exists. Skipping configuration."
fi

# Inform the user that the setup is complete
echo "Sway and basic utilities have been installed and configured."
echo "To start Sway, log out and select Sway from your display manager, or run 'sway' from a TTY."
