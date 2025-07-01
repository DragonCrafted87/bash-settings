#!/bin/bash
# Script to deploy network-wait service, install htop, and optionally deploy boinc scripts and configure BOINC RPC on openSUSE Leap 15.6
# Idempotent: checks for existing files, packages, and service states
# Run with sudo from setup/openSUSE/ directory or specify repository path
# Use --with-boinc to include BOINC setup, otherwise BOINC steps are skipped

set -e

# Default: skip BOINC setup unless --with-boinc is provided
WITH_BOINC=false

# Parse command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --with-boinc)
            WITH_BOINC=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--with-boinc]"
            exit 1
            ;;
    esac
done

# Define paths
REPO_DIR="$(dirname "$(realpath "$0")")"
SERVICE_SRC="${REPO_DIR}/systemd/network-wait.service"
SCRIPT_SRC="${REPO_DIR}/systemd/wait-for-network.sh"
SERVICE_DEST="/etc/systemd/system/network-wait.service"
SCRIPT_DEST="/usr/local/bin/wait-for-network.sh"

# BOINC paths (only used if WITH_BOINC is true)
BOINC_CONFIG_SRC="${REPO_DIR}/boinc/boinc-config.sh"
BOINC_STATUS_SRC="${REPO_DIR}/boinc/boinc-status.sh"
BOINC_CONFIG_DEST="/usr/local/bin/boinc-config.sh"
BOINC_STATUS_DEST="/usr/local/bin/boinc-status.sh"
BOINC_DIR="/var/lib/boinc"
RPC_AUTH_FILE="${BOINC_DIR}/gui_rpc_auth.cfg"

# Check if source files exist (always check network-wait files, conditionally check BOINC files)
for SRC in "$SERVICE_SRC" "$SCRIPT_SRC"; do
    if [ ! -f "$SRC" ]; then
        echo "Error: $SRC not found"
        exit 1
    fi
done
if [ "$WITH_BOINC" = true ]; then
    for SRC in "$BOINC_CONFIG_SRC" "$BOINC_STATUS_SRC"; do
        if [ ! -f "$SRC" ]; then
            echo "Error: $SRC not found"
            exit 1
        fi
    done
fi

# Check and install htop (and boinc-client if WITH_BOINC is true)
echo "Checking for htop..."
if ! rpm -q htop >/dev/null 2>&1; then
    echo "Installing htop..."
    zypper --non-interactive install htop
else
    echo "htop is already installed"
fi

if [ "$WITH_BOINC" = true ]; then
    echo "Checking for boinc-client..."
    if ! rpm -q boinc-client >/dev/null 2>&1; then
        echo "Installing boinc-client..."
        zypper --non-interactive install boinc-client
    else
        echo "boinc-client is already installed"
    fi
fi

# Configure BOINC RPC authentication (only if WITH_BOINC is true)
if [ "$WITH_BOINC" = true ]; then
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
fi

# Check and deploy files
echo "Checking and deploying files..."
declare -A FILE_PAIRS=(
    ["$SERVICE_SRC"]="$SERVICE_DEST"
    ["$SCRIPT_SRC"]="$SCRIPT_DEST"
)
if [ "$WITH_BOINC" = true ]; then
    FILE_PAIRS["$BOINC_CONFIG_SRC"]="$BOINC_CONFIG_DEST"
    FILE_PAIRS["$BOINC_STATUS_SRC"]="$BOINC_STATUS_DEST"
fi
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
echo "Ensuring executable permissions for $SCRIPT_DEST..."
chmod +x "$SCRIPT_DEST"
if [ "$WITH_BOINC" = true ]; then
    echo "Ensuring executable permissions for $BOINC_CONFIG_DEST and $BOINC_STATUS_DEST..."
    chmod +x "$BOINC_CONFIG_DEST" "$BOINC_STATUS_DEST"
fi

# Enable and start boinc-client service if WITH_BOINC is true and not already enabled/started
if [ "$WITH_BOINC" = true ]; then
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
if [ "$WITH_BOINC" = true ]; then
    echo "Checking boinc-client service status..."
    systemctl status boinc-client --no-pager
fi

echo "Setup complete."
if [ "$WITH_BOINC" = true ]; then
    echo "Run 'sudo /usr/local/bin/boinc-config.sh' to configure BOINC for Science United."
    echo "Run 'sudo /usr/local/bin/boinc-status.sh' to check BOINC status."
fi
exit 0
