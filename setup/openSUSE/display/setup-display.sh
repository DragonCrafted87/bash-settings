#!/bin/bash
# Subcontrol script to deploy display idle and lid control settings on openSUSE Leap 15.6
# Idempotent: checks for existing files, packages, and service states
# Run with sudo from setup/openSUSE/display/ directory or via main script
# Use --with-display-idle for display idle setup, --with-lid-control for lid sleep control

set -e

# Defaults: skip components unless specified
WITH_DISPLAY_IDLE=false
WITH_LID_CONTROL=false

# Parse command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --with-display-idle)
            WITH_DISPLAY_IDLE=true
            shift
            ;;
        --with-lid-control)
            WITH_LID_CONTROL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--with-display-idle] [--with-lid-control]"
            exit 1
            ;;
    esac
done

# Check if at least one component is selected
if [ "$WITH_DISPLAY_IDLE" = false ] && [ "$WITH_LID_CONTROL" = false ]; then
    echo "No components selected. Use --with-display-idle and/or --with-lid-control."
    exit 1
fi

# Define paths
REPO_DIR="$(dirname "$(realpath "$0")")"
DISPLAY_SERVICE_SRC="${REPO_DIR}/display-idle.service"
DISPLAY_SCRIPT_SRC="${REPO_DIR}/display_off_idle.sh"
DISPLAY_LID_SCRIPT_SRC="${REPO_DIR}/disable-lid-sleep.sh"
DISPLAY_SERVICE_DEST="/etc/systemd/system/display-idle.service"
DISPLAY_SCRIPT_DEST="/usr/local/bin/display_off_idle.sh"
DISPLAY_LID_SCRIPT_DEST="/usr/local/bin/disable-lid-sleep.sh"

# Check if source files exist
if [ "$WITH_DISPLAY_IDLE" = true ]; then
    for SRC in "$DISPLAY_SERVICE_SRC" "$DISPLAY_SCRIPT_SRC"; do
        if [ ! -f "$SRC" ]; then
            echo "Error: $SRC not found"
            exit 1
        fi
    done
fi
if [ "$WITH_LID_CONTROL" = true ]; then
    if [ ! -f "$DISPLAY_LID_SCRIPT_SRC" ]; then
        echo "Error: $DISPLAY_LID_SCRIPT_SRC not found"
        exit 1
    fi
fi

# Check and install dependencies for display-idle
if [ "$WITH_DISPLAY_IDLE" = true ]; then
    echo "Checking for inotify-tools..."
    if ! rpm -q inotify-tools >/dev/null 2>&1; then
        echo "Installing inotify-tools..."
        zypper --non-interactive install inotify-tools || { echo "Error: Failed to install inotify-tools"; exit 1; }
    else
        echo "inotify-tools is already installed"
    fi
    echo "Checking for vbetool..."
    if ! rpm -q vbetool >/dev/null 2>&1; then
        echo "Adding home:tiwai repository for vbetool..."
        if ! zypper lr | grep -q "home_tiwai"; then
            zypper addrepo -f -n "home:tiwai" https://download.opensuse.org/repositories/home:tiwai/15.6/ home_tiwai || { echo "Error: Failed to add home:tiwai repository"; exit 1; }
            zypper refresh || { echo "Error: Failed to refresh repositories"; exit 1; }
        else
            echo "home:tiwai repository already exists"
        fi
        echo "Installing vbetool..."
        zypper --non-interactive install vbetool || { echo "Error: vbetool not found in repositories, required for TTY display control"; exit 1; }
    else
        echo "vbetool is already installed"
    fi
    # Optional: wlr-randr for Sway Wayland sessions
    echo "Checking for wlr-randr..."
    if ! rpm -q wlr-randr >/dev/null 2>&1; then
        echo "wlr-randr not found. Sway display control will not work."
        echo "To install: sudo zypper install wlr-randr"
    else
        echo "wlr-randr is already installed"
    fi
fi

# Check and deploy files
echo "Checking and deploying display files..."
declare -A FILE_PAIRS=()
if [ "$WITH_DISPLAY_IDLE" = true ]; then
    FILE_PAIRS["$DISPLAY_SERVICE_SRC"]="$DISPLAY_SERVICE_DEST"
    FILE_PAIRS["$DISPLAY_SCRIPT_SRC"]="$DISPLAY_SCRIPT_DEST"
fi
if [ "$WITH_LID_CONTROL" = true ]; then
    FILE_PAIRS["$DISPLAY_LID_SCRIPT_SRC"]="$DISPLAY_LID_SCRIPT_DEST"
fi
for SRC in "${!FILE_PAIRS[@]}"; do
    DEST="${FILE_PAIRS[$SRC]}"
    if [ -f "$DEST" ] && cmp -s "$SRC" "$DEST"; then
        echo "$DEST is already up to date"
    else
        echo "Copying $SRC to $DEST..."
        cp "$SRC" "$DEST" || { echo "Error: Failed to copy $SRC to $DEST"; exit 1; }
    fi
done

# Set permissions for scripts
if [ "$WITH_DISPLAY_IDLE" = true ]; then
    echo "Ensuring executable permissions for $DISPLAY_SCRIPT_DEST..."
    chmod +x "$DISPLAY_SCRIPT_DEST" || { echo "Error: Failed to set permissions for $DISPLAY_SCRIPT_DEST"; exit 1; }
fi
if [ "$WITH_LID_CONTROL" = true ]; then
    echo "Ensuring executable permissions for $DISPLAY_LID_SCRIPT_DEST..."
    chmod +x "$DISPLAY_LID_SCRIPT_DEST" || { echo "Error: Failed to set permissions for $DISPLAY_LID_SCRIPT_DEST"; exit 1; }
fi

# Run disable-lid-sleep.sh if WITH_LID_CONTROL is true
if [ "$WITH_LID_CONTROL" = true ]; then
    echo "Running disable-lid-sleep.sh to disable sleep on lid close..."
    bash "$DISPLAY_LID_SCRIPT_DEST" || { echo "Error: Failed to run $DISPLAY_LID_SCRIPT_DEST"; exit 1; }
fi

# Enable and start display-idle service if WITH_DISPLAY_IDLE is true
if [ "$WITH_DISPLAY_IDLE" = true ]; then
    echo "Reloading systemd daemon..."
    systemctl daemon-reload || { echo "Error: Failed to reload systemd daemon"; exit 1; }
    echo "Checking display-idle.service..."
    if ! systemctl is-enabled --quiet display-idle.service; then
        echo "Enabling display-idle.service..."
        systemctl enable display-idle.service || { echo "Error: Failed to enable display-idle.service"; exit 1; }
    else
        echo "display-idle.service is already enabled"
    fi
    if ! systemctl is-active --quiet display-idle.service; then
        echo "Starting display-idle.service..."
        systemctl start display-idle.service || { echo "Error: Failed to start display-idle.service"; exit 1; }
    else
        echo "display-idle.service is already running"
    fi
    # Verify service status
    echo "Checking display-idle.service status..."
    systemctl status display-idle.service --no-pager || echo "Note: display-idle.service status check returned non-zero, but continuing"
fi

echo "Display setup complete."
exit 0
