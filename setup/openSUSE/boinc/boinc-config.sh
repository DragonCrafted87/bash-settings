#!/bin/bash
# Script to configure BOINC client to connect to Science United project
# Idempotent: checks for existing connection and prompts to replace or skip
# Handles RPC authentication for boinccmd
# Prompts for user credentials and attaches to the project if needed

# Science United project URL
PROJECT_URL="https://scienceunited.org/"

# BOINC data directory
BOINC_DIR="/var/lib/boinc"
RPC_AUTH_FILE="${BOINC_DIR}/gui_rpc_auth.cfg"

echo "Configuring BOINC client for Science United project..."

# Check if boinc-client is running
if ! systemctl is-active --quiet boinc-client; then
    echo "Error: boinc-client service is not running. Start it with 'sudo systemctl start boinc-client'."
    exit 1
fi

# Check for gui_rpc_auth.cfg
if [ ! -f "$RPC_AUTH_FILE" ]; then
    echo "Error: $RPC_AUTH_FILE not found. BOINC RPC authentication is required."
    echo "To fix this, generate the file or configure BOINC for passwordless RPC."
    echo "1. Stop the BOINC client: 'sudo systemctl stop boinc-client'"
    echo "2. Create $RPC_AUTH_FILE with a password (e.g., 'echo mypassword > $RPC_AUTH_FILE')"
    echo "3. Set permissions: 'sudo chown boinc:boinc $RPC_AUTH_FILE; sudo chmod 640 $RPC_AUTH_FILE'"
    echo "4. Start the BOINC client: 'sudo systemctl start boinc-client'"
    echo "Then rerun this script."
    exit 1
fi

# Read RPC password
if ! RPC_PASSWORD=$(cat "$RPC_AUTH_FILE"); then
    echo "Error: Failed to read RPC password from $RPC_AUTH_FILE. Check file permissions."
    echo "Ensure the file is readable by the boinc user and this script (run with sudo)."
    exit 1
fi

# Check if already attached to Science United
if boinccmd --passwd "$RPC_PASSWORD" --get_project_status | grep -q "$PROJECT_URL"; then
    echo "BOINC is already attached to Science United."
    echo "Do you want to replace the existing connection with new credentials? (y/n)"
    read -p "Enter your choice (y/n): " REPLACE
    if [[ ! "$REPLACE" =~ ^[Yy]$ ]]; then
        echo "Skipping configuration. To manage projects, use 'boinccmd --project <url> <command>'."
        exit 0
    fi
    echo "Detaching from existing Science United project..."
    if ! boinccmd --passwd "$RPC_PASSWORD" --project "$PROJECT_URL" detach; then
        echo "Error: Failed to detach from Science United. Check BOINC status with 'boinccmd --passwd <password> --get_project_status'."
        exit 1
    fi
    echo "Detached successfully. Proceeding with new configuration..."
fi

# Prompt for credentials
echo "You need a Science United account to proceed."
echo "If you don't have one, create an account at https://scienceunited.org/ and note your username and password."
read -p "Enter your Science United username: " USERNAME
if [ -z "$USERNAME" ]; then
    echo "Error: Username cannot be empty."
    exit 1
fi

# Prompt for password securely
read -s -p "Enter your Science United password: " PASSWORD
echo
if [ -z "$PASSWORD" ]; then
    echo "Error: Password cannot be empty."
    exit 1
fi

# Attempt to attach to the project
echo "Attaching to Science United project..."
if ! boinccmd --passwd "$RPC_PASSWORD" --project_attach "$PROJECT_URL" "$USERNAME" "$PASSWORD"; then
    echo "Error: Failed to attach to Science United. Please check your credentials or network connection."
    echo "You can try again by running this script or manually with:"
    echo "  boinccmd --passwd <rpc_password> --project_attach $PROJECT_URL <username> <password>"
    exit 1
fi

# Verify attachment
echo "Verifying project attachment..."
sleep 2 # Wait briefly for BOINC to update
if boinccmd --passwd "$RPC_PASSWORD" --get_project_status | grep -q "$PROJECT_URL"; then
    echo "Successfully attached to Science United!"
    echo "BOINC is now configured to contribute to Science United projects."
else
    echo "Warning: Project attachment may have failed. Check status with 'boinccmd --passwd <rpc_password> --get_project_status'."
    exit 1
fi

echo "You can monitor BOINC tasks with 'boinccmd --passwd <rpc_password> --get_tasks' or install boinc-manager for a GUI."
exit 0
