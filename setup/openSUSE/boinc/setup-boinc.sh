#!/bin/bash
# Subcontrol script to deploy BOINC client and scripts on openSUSE Leap 15.6
# Idempotent: checks for existing files, packages, and service states
# Run with sudo from setup/openSUSE/boinc/ directory or via main script

set -e

# Define paths
REPO_DIR="$(dirname "$(realpath "$0")")"
BOINC_CONFIG_SRC="${REPO_DIR}/boinc-config.sh"
BOINC_STATUS_SRC="${REPO_DIR}/boinc-status.sh"
BOINC_CONFIG_DEST="/usr/local/bin/boinc-config.sh"
BOINC_STATUS_DEST="/usr/local/bin/boinc-status.sh"
BOINC_DIR="/var/lib/boinc"
RPC_AUTH_FILE="${BOINC_DIR}/gui_rpc_auth.cfg"

# Check if source files exist
for SRC in "$BOINC_CONFIG_SRC" "$BOINC_STATUS_SRC"; do
    if [ ! -f "$SRC" ]; then
        echo "Error: $SRC not found"
        exit 1
    fi
done

# Check and install boinc-client
echo "Checking for boinc-client..."
if ! rpm -q boinc-client >/dev/null 2>&1; then
    echo "Installing boinc-client..."
    zypper --non-interactive install boinc-client
else
    echo "boinc-client is already installed"
fi

# Configure BOINC RPC authentication
echo "Checking BOINC RPC configuration..."
if [ ! -f "$RPC_AUTH_FILE" ]; then
    echo "Creating $RPC_AUTH_FILE with random password..."
    # Generate a random 32-character password
    RPC_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
    echo "$RPC_PASSWORD" > "$RPC_AUTH_FILE"
    chown boinc:boinc "$RPC_AUTH_FILE"
    chmod 640 "$RPC_AUTH_FILE"
    echo "RPC password generated and configured"
else
    echo "$RPC_AUTH_FILE already exists"
fi

# Check and deploy files
echo "Checking and deploying BOINC files..."
declare -A FILE_PAIRS=(
    ["$BOINC_CONFIG_SRC"]="$BOINC_CONFIG_DEST"
    ["$BOINC_STATUS_SRC"]="$BOINC_STATUS_DEST"
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
echo "Ensuring executable permissions for $BOINC_CONFIG_DEST and $BOINC_STATUS_DEST..."
chmod +x "$BOINC_CONFIG_DEST" "$BOINC_STATUS_DEST"

# Enable and start boinc-client service
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

# Verify service status
echo "Checking boinc-client service status..."
systemctl status boinc-client --no-pager

echo "BOINC setup complete."
exit 0
