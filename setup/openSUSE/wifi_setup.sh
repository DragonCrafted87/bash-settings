#!/bin/bash

# Script to set up WLAN to autoconnect on openSUSE Leap 15.6
# Run as the 'dragon' user with sudo privileges

# Exit on error
set -e

# Check if running as the 'dragon' user and not root
if [ "$(id -u)" -eq 0 ] || [ "$(whoami)" != "dragon" ]; then
    echo "Error: This script must be run as the 'dragon' user, not as root or another user."
    exit 1
fi

# Check if zypper is available for package installation
if ! command -v zypper &> /dev/null; then
    echo "Error: zypper is not installed. Cannot install required commands."
    exit 1
fi

# Ensure nmcli is installed
if ! command -v nmcli &> /dev/null; then
    echo "nmcli is not installed. Attempting to install NetworkManager..."
    sudo zypper install -y NetworkManager || {
        echo "Error: Failed to install NetworkManager. Please install it manually."
        exit 1
    }
    echo "nmcli is available"
fi

# Ensure NetworkManager is enabled and running
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
if ! systemctl is-active --quiet NetworkManager; then
    echo "Error: NetworkManager failed to start"
    exit 1
fi
echo "NetworkManager is enabled and running"

# Check for wireless interface
WLAN_IFACE=$(nmcli -t -f DEVICE,TYPE dev | grep wifi | cut -d: -f1)
if [ -z "$WLAN_IFACE" ]; then
    echo "Error: No wireless interface found. Please ensure your wireless adapter is working."
    echo "Run 'rfkill list' to check for blocks and 'rfkill unblock all' if needed."
    exit 1
fi
echo "Wireless interface found: $WLAN_IFACE"

# Scan for available Wi-Fi networks
echo "Scanning for available Wi-Fi networks..."
SSIDS=$(nmcli -t -f SSID,SIGNAL dev wifi list | grep -v '^$' | sort -t: -k2 -nr | awk -F: '{print $1}' | uniq)
if [ -z "$SSIDS" ]; then
    echo "Error: No Wi-Fi networks found. Please ensure your wireless adapter is active."
    exit 1
fi

# Display SSIDs with numbers
echo "Available Wi-Fi networks:"
select SSID in $SSIDS "Quit"; do
    if [ "$SSID" = "Quit" ] || [ -z "$SSID" ]; then
        echo "Exiting without configuring Wi-Fi."
        exit 0
    fi
    echo "Selected SSID: $SSID"
    break
done

# Check if the connection already exists
if nmcli con show "$SSID" &> /dev/null; then
    echo "Connection for $SSID already exists. Updating autoconnect settings..."
    nmcli con mod "$SSID" connection.autoconnect yes
else
    # Prompt for Wi-Fi password
    read -sp "Enter Wi-Fi password for $SSID (leave blank for open network): " WLAN_PASSWORD
    echo

    echo "Creating new connection for $SSID..."
    if [ -n "$WLAN_PASSWORD" ]; then
        # Configure WPA-PSK secured network
        nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "$WLAN_IFACE" \
            wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$WLAN_PASSWORD" connection.autoconnect yes || {
            echo "Error: Failed to create WLAN connection for $SSID"
            exit 1
        }
    else
        # Configure open network
        nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "$WLAN_IFACE" \
            connection.autoconnect yes || {
            echo "Error: Failed to create WLAN connection for $SSID"
            exit 1
        }
    fi
fi
echo "WLAN connection for $SSID configured to autoconnect"

# Attempt to bring up the connection
echo "Attempting to connect to $SSID..."
nmcli con up "$SSID" || {
    echo "Warning: Failed to connect to $SSID. Please check the password or network availability."
}

echo "Wi-Fi setup complete. Reboot or run 'nmcli con up \"$SSID\"' to test connectivity."
