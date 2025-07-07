#!/bin/bash
# Main script to coordinate setup of network-wait, BOINC, display idle, and lid control on openSUSE Leap 15.6
# Idempotent: delegates to subcontrol scripts in subdirectories
# Run with sudo from setup/openSUSE/ directory
# Use --with-boinc, --with-display-idle, --with-lid-control, or --interactive for menu-driven setup

set -e

# Defaults: skip optional components unless specified
WITH_BOINC=false
WITH_DISPLAY_IDLE=false
WITH_LID_CONTROL=false
INTERACTIVE=false

# Parse command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --with-boinc)
            WITH_BOINC=true
            shift
            ;;
        --with-display-idle)
            WITH_DISPLAY_IDLE=true
            shift
            ;;
        --with-lid-control)
            WITH_LID_CONTROL=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--with-boinc] [--with-display-idle] [--with-lid-control] [--interactive]"
            exit 1
            ;;
    esac
done

# Define paths
REPO_DIR="$(dirname "$(realpath "$0")")"
SYSTEMD_SCRIPT="${REPO_DIR}/systemd/setup-systemd.sh"
BOINC_SCRIPT="${REPO_DIR}/boinc/setup-boinc.sh"
DISPLAY_SCRIPT="${REPO_DIR}/display/setup-display.sh"

# Check if subcontrol scripts exist
for SCRIPT in "$SYSTEMD_SCRIPT"; do
    if [ ! -f "$SCRIPT" ]; then
        echo "Error: $SCRIPT not found"
        exit 1
    fi
done
if [ "$WITH_BOINC" = true ] || [ "$INTERACTIVE" = true ]; then
    if [ ! -f "$BOINC_SCRIPT" ]; then
        echo "Error: $BOINC_SCRIPT not found"
        exit 1
    fi
fi
if [ "$WITH_DISPLAY_IDLE" = true ] || [ "$WITH_LID_CONTROL" = true ] || [ "$INTERACTIVE" = true ]; then
    if [ ! -f "$DISPLAY_SCRIPT" ]; then
        echo "Error: $DISPLAY_SCRIPT not found"
        exit 1
    fi
fi

# Interactive menu using dialog
if [ "$INTERACTIVE" = true ]; then
    # Check and install dialog if not present
    echo "Checking for dialog..."
    if ! rpm -q dialog >/dev/null 2>&1; then
        echo "Installing dialog..."
        zypper --non-interactive install dialog
    else
        echo "dialog is already installed"
    fi

    # Reset flags to false to avoid conflicts with command-line flags
    WITH_BOINC=false
    WITH_DISPLAY_IDLE=false
    WITH_LID_CONTROL=false

    # Create temporary file for dialog output
    TEMP_FILE=$(mktemp)

    # Display menu
    dialog --checklist "Select components to install (network-wait is always installed):" 15 60 4 \
        "boinc" "BOINC client and scripts" off \
        "display-idle" "Display idle monitor service" off \
        "lid-control" "Disable sleep on lid close" off 2> "$TEMP_FILE"

    # Check if user cancelled
    if [ $? -ne 0 ]; then
        echo "Interactive setup cancelled."
        rm -f "$TEMP_FILE"
        exit 0
    fi

    # Read selections
    SELECTIONS=$(cat "$TEMP_FILE" | tr -d '"')
    rm -f "$TEMP_FILE"

    # Set flags based on selections
    for SELECTION in $SELECTIONS; do
        case "$SELECTION" in
            boinc)
                WITH_BOINC=true
                ;;
            display-idle)
                WITH_DISPLAY_IDLE=true
                ;;
            lid-control)
                WITH_LID_CONTROL=true
                ;;
        esac
    done
fi

# Check and install htop (common dependency)
echo "Checking for htop..."
if ! rpm -q htop >/dev/null 2>&1; then
    echo "Installing htop..."
    zypper --non-interactive install htop
else
    echo "htop is already installed"
fi

# Run subcontrol scripts based on flags
echo "Running network-wait setup..."
bash "$SYSTEMD_SCRIPT"

if [ "$WITH_BOINC" = true ]; then
    echo "Running BOINC setup..."
    bash "$BOINC_SCRIPT"
fi

if [ "$WITH_DISPLAY_IDLE" = true ] || [ "$WITH_LID_CONTROL" = true ]; then
    echo "Running display setup..."
    bash "$DISPLAY_SCRIPT" \
        $([ "$WITH_DISPLAY_IDLE" = true ] && echo "--with-display-idle") \
        $([ "$WITH_LID_CONTROL" = true ] && echo "--with-lid-control")
fi

echo "Setup complete."
if [ "$WITH_BOINC" = true ]; then
    echo "Run 'sudo /usr/local/bin/boinc-config.sh' to configure BOINC for Science United."
    echo "Run 'sudo /usr/local/bin/boinc-status.sh' to check BOINC status."
fi
if [ "$WITH_DISPLAY_IDLE" = true ]; then
    echo "Display idle settings applied. Monitor logs with: journalctl -u display-idle.service -n 100 -f"
fi
if [ "$WITH_LID_CONTROL" = true ]; then
    echo "Lid sleep control applied. Monitor logs with: journalctl -u systemd-logind -n 100 -f"
fi
exit 0
