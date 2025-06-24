#!/bin/bash
# Script to deploy network-wait service, install htop and boinc, and deploy boinc configuration script on openSUSE Leap 15.6
# Idempotent: checks for existing files, packages, and service states
# Run with sudo from setup/openSUSE/ directory or specify repository path

set -e

# Define paths
REPO_DIR="$(dirname "$(realpath "$0")")"
SERVICE_SRC="${REPO_DIR}/systemd/network-wait.service"
SCRIPT_SRC="${REPO_DIR}/systemd/wait-for-network.sh"
BOINC_SCRIPT_SRC="${REPO_DIR}/boinc/boinc-config.sh"
SERVICE_DEST="/etc/systemd/system/network-wait.service"
SCRIPT_DEST="/usr/local/bin/wait-for-network.sh"
BOINC_SCRIPT_DEST="/usr/local/bin/boinc-config.sh"

# Check if source files exist
for SRC in "$SERVICE_SRC" "$SCRIPT_SRC" "$BOINC_SCRIPT_SRC"; do
    if [ ! -f "$SRC" ]; then
        echo "Error: $SRC not found"
        exit 1
    fi
done

# Check and install htop and boinc-client if not already installed
echo "Checking for htop and boinc-client..."
if ! rpm -q htop boinc-client >/dev/null 2>&1; then
    echo "Installing htop and boinc-client..."
    zypper --non-interactive install htop boinc-client
else
    echo "htop and boinc-client are already installed"
fi

# Check and deploy files
echo "Checking and deploying files..."
declare -A FILE_PAIRS=(
    ["$SERVICE_SRC"]="$SERVICE_DEST"
    ["$SCRIPT_SRC"]="$SCRIPT_DEST"
    ["$BOINC_SCRIPT_SRC"]="$BOINC_SCRIPT_DEST"
)
for SRC in "${!FILE_PAIRS[@]}"; do
    DEST="${FILE_PAIRS[$SRC]}"
    if [ -f "$DEST" ] && cmp -s "$SRC" "$DEST"; then
        echo "$DEST is already up to date"
    else
        echo "Copying $SRC to $DEST..."
        cp "$SRC" "$DEST"
    fi
done

# Set permissions for scripts
echo "Ensuring executable permissions for $SCRIPT_DEST and $BOINC_SCRIPT_DEST..."
chmod +x "$SCRIPT_DEST" "$BOINC_SCRIPT_DEST"

# Enable and start boinc-client service if not already enabled/started
echo "Checking boinc-client service..."
if ! systemctl is-enabled --quiet boinc-client; then
    echo "Enabling boinc-client service..."
    systemctl enable boinc-client
else
    echo "boinc-client service is already enabled"
fi
if ! systemctl is-active --quiet boinc-client; then
    echo "Starting boinc-client service..."
    systemctl start boinc-client
else
    echo "boinc-client service is already running"
fi

# Reload systemd and enable network-wait service
echo "Reloading systemd daemon..."
systemctl daemon-reload
echo "Checking network-wait.service..."
if ! systemctl is-enabled --quiet network-wait.service; then
    echo "Enabling network-wait.service..."
    systemctl enable network-wait.service
else
    echo "network-wait.service is already enabled"
fi

# Verify service statuses
echo "Checking network-wait.service status..."
systemctl status network-wait.service --no-pager
echo "Checking boinc-client service status..."
systemctl status boinc-client --no-pager

echo "Setup complete. Run 'sudo /usr/local/bin/boinc-config.sh' to configure BOINC for Science United."
echo "Reboot to test the network-wait service if changes were made."
exit 0
