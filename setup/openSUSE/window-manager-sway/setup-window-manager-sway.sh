#!/bin/bash
# Subcontrol script to set up Sway window manager on openSUSE Leap 15.6
# Idempotent: checks for existing packages and configurations
# Run with sudo from setup/openSUSE/window-manager-sway/ directory or via main script

set -e

# Determine the directory of this script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Check and install curl (needed for Brave repository)
echo "Checking for curl..."
if ! rpm -q curl >/dev/null 2>&1; then
    echo "Installing curl..."
    sudo zypper install -y curl
else
    echo "curl is already installed"
fi

# Check and add Brave repository
echo "Checking Brave repository..."
if ! zypper lr | grep -q "brave-browser"; then
    echo "Adding Brave repository..."
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
else
    echo "Brave repository already exists"
fi

# Refresh repositories
echo "Refreshing repositories..."
sudo zypper refresh

# Install Sway and dependencies
echo "Checking Sway and dependencies..."
PACKAGES="sway sway-branding-upstream wofi jq mpv python3-pip brave-browser pipewire pipewire-pulseaudio pipewire-alsa pavucontrol"
for PKG in $PACKAGES; do
    if ! rpm -q "$PKG" >/dev/null 2>&1; then
        echo "Installing $PKG..."
        sudo zypper install -y "$PKG"
    else
        echo "$PKG is already installed"
    fi
done

# Install jellyfin-mpv-shim
echo "Checking jellyfin-mpv-shim..."
if ! pip3 show jellyfin-mpv-shim >/dev/null 2>&1; then
    echo "Installing jellyfin-mpv-shim..."
    sudo pip3 install --upgrade jellyfin-mpv-shim
else
    echo "jellyfin-mpv-shim is already installed"
fi

# Enable PipeWire user services for audio
echo "Checking PipeWire services..."
for SERVICE in pipewire.service pipewire-pulse.service; do
    if ! systemctl --user is-enabled --quiet "$SERVICE"; then
        echo "Enabling $SERVICE..."
        systemctl --user enable "$SERVICE"
    else
        echo "$SERVICE is already enabled"
    fi
    if ! systemctl --user is-active --quiet "$SERVICE"; then
        echo "Starting $SERVICE..."
        systemctl --user start "$SERVICE"
    else
        echo "$SERVICE is already running"
    fi
done

# Set up Sway configuration
echo "Setting up Sway configuration..."
mkdir -p ~/.config/sway
if [ ! -f ~/.config/sway/config ]; then
    echo "Copying default Sway configuration..."
    cp /etc/sway/config ~/.config/sway/config
else
    echo "Sway configuration already exists"
fi

# Add autostart for jellyfin-mpv-shim
if ! grep -q "exec jellyfin-mpv-shim" ~/.config/sway/config; then
    echo "Adding jellyfin-mpv-shim to Sway autostart..."
    echo "exec jellyfin-mpv-shim" >> ~/.config/sway/config
else
    echo "jellyfin-mpv-shim already in Sway autostart"
fi

# Ensure auxiliary scripts are executable
if [ -f "$SCRIPT_DIR/update-keybinding.sh" ]; then
    echo "Ensuring executable permissions for update-keybinding.sh..."
    chmod +x "$SCRIPT_DIR/update-keybinding.sh"
else
    echo "Warning: $SCRIPT_DIR/update-keybinding.sh not found"
fi

# Run auxiliary script
if [ -f "$SCRIPT_DIR/update-keybinding.sh" ]; then
    echo "Running update-keybinding.sh..."
    "$SCRIPT_DIR/update-keybinding.sh"
else
    echo "Skipping update-keybinding.sh (not found)"
fi

# Check if Sway is running and restart it if necessary
echo "Checking Sway status..."
if swaymsg -t get_version >/dev/null 2>&1; then
    echo "Restarting Sway by exiting current session..."
    swaymsg exit  # This exits Sway, allowing the user to log back in
else
    echo "Sway is not running."
fi

echo "Sway setup complete."
exit 0
