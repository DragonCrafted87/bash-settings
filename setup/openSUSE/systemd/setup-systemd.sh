#!/bin/bash
# Subcontrol script to deploy network-wait service on openSUSE Leap 15.6
# Idempotent: checks for existing files and service states
# Run with sudo from setup/openSUSE/systemd/ directory or via main script

set -e

# Define paths
REPO_DIR="$(dirname "$(realpath "$0")")"
SERVICE_SRC="${REPO_DIR}/network-wait.service"
SCRIPT_SRC="${REPO_DIR}/wait-for-network.sh"
SERVICE_DEST="/etc/systemd/system/network-wait.service"
SCRIPT_DEST="/usr/local/bin/wait-for-network.sh"

# Check if source files exist
for SRC in "$SERVICE_SRC" "$SCRIPT_SRC"; do
    if [ ! -f "$SRC" ]; then
        echo "Error: $SRC not found"
        exit 1
    fi
    echo "DEBUG: Found $SRC"
done

# Check and deploy files
echo "Checking and deploying network-wait files..."
declare -A FILE_PAIRS=(
    ["$SERVICE_SRC"]="$SERVICE_DEST"
    ["$SCRIPT_SRC"]="$SCRIPT_DEST"
)
for SRC in "${!FILE_PAIRS[@]}"; do
    DEST="${FILE_PAIRS[$SRC]}"
    if [ -f "$DEST" ] && cmp -s "$SRC" "$DEST"; then
        echo "$DEST is already up to date"
    else
        echo "Copying $SRC to $DEST..."
        cp "$SRC" "$DEST" || { echo "Error: Failed to copy $SRC to $DEST"; exit 1; }
    fi
    echo "DEBUG: Processed $SRC to $DEST"
done

# Set permissions for script
echo "Ensuring executable permissions for $SCRIPT_DEST..."
chmod +x "$SCRIPT_DEST" || { echo "Error: Failed to set permissions for $SCRIPT_DEST"; exit 1; }
echo "DEBUG: Set permissions for $SCRIPT_DEST"

# Reload systemd
echo "Reloading systemd daemon..."
systemctl daemon-reload || { echo "Error: Failed to reload systemd daemon"; exit 1; }
echo "DEBUG: Reloaded systemd daemon"

# Enable network-wait service
echo "Checking network-wait.service..."
if ! systemctl is-enabled --quiet network-wait.service; then
    echo "Enabling network-wait.service..."
    systemctl enable network-wait.service || { echo "Error: Failed to enable network-wait.service"; exit 1; }
else
    echo "network-wait.service is already enabled"
fi
echo "DEBUG: Checked/enabled network-wait.service"

# Verify service status (use --no-pager and redirect output to avoid exit code issues)
echo "Checking network-wait.service status..."
systemctl status network-wait.service --no-pager > /dev/null || echo "Note: network-wait.service status check returned non-zero, but continuing"
systemctl status network-wait.service --no-pager
echo "DEBUG: Checked network-wait.service status"

echo "Network-wait setup complete."
exit 0
