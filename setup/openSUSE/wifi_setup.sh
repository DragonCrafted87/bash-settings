#!/bin/bash

# Script to set up WLAN to autoconnect on openSUSE Leap 15.6 using wicked
# Run as the 'dragon' user with sudo privileges

# Exit on error
set -e

# Variables
NETWORK_CONFIG_DIR="/etc/sysconfig/network"
WPA_SUPPLICANT_CONF="/etc/wpa_supplicant.conf"

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

# Ensure required commands are installed
for cmd in wicked iwlist wpa_supplicant; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "$cmd is not installed. Attempting to install..."
        sudo zypper install -y "$cmd" || {
            echo "Error: Failed to install $cmd. Please install it manually."
            exit 1
        }
    fi
    echo "$cmd is available"
done

# Check for wireless interface
WLAN_IFACE=$(ip link | grep -E '^[0-9]+: wlan' | awk '{print $2}' | sed 's/:$//' | head -n 1)
if [ -z "$WLAN_IFACE" ]; then
    echo "Error: No wireless interface found. Please ensure your wireless adapter is working."
    echo "Run 'rfkill list' to check for blocks and 'rfkill unblock all' if needed."
    exit 1
fi
echo "Wireless interface found: $WLAN_IFACE"

# Scan for available Wi-Fi networks
echo "Scanning for available Wi-Fi networks..."
sudo iwlist "$WLAN_IFACE" scan > /dev/null 2>&1 || {
    echo "Error: Failed to scan for Wi-Fi networks. Ensure the wireless interface is up."
    echo "Try 'sudo ip link set $WLAN_IFACE up' and re-run the script."
    exit 1
}
SSIDS=$(sudo iwlist "$WLAN_IFACE" scan | grep 'ESSID:' | sed 's/.*ESSID:"\([^"]*\)"/\1/' | sort | uniq | grep -v '^$')
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

# Prompt for Wi-Fi password
read -sp "Enter Wi-Fi password for $SSID (leave blank for open network): " WLAN_PASSWORD
echo

# Generate interface configuration file
IFCFG_FILE="$NETWORK_CONFIG_DIR/ifcfg-$SSID"
if [ -f "$IFCFG_FILE" ]; then
    echo "Configuration for $SSID already exists. Updating settings..."
else
    echo "Creating new configuration for $SSID..."
fi

# Write interface configuration
sudo tee "$IFCFG_FILE" > /dev/null << EOF
BOOTPROTO='dhcp'
STARTMODE='auto'
WIRELESS='yes'
WIRELESS_ESSID='$SSID'
WIRELESS_MODE='Managed'
EOF

# Configure WPA-PSK if password provided
if [ -n "$WLAN_PASSWORD" ]; then
    echo "Configuring WPA-PSK for $SSID..."
    sudo tee -a "$IFCFG_FILE" > /dev/null << EOF
WIRELESS_AUTH_MODE='psk'
WIRELESS_WPA_PSK='$WLAN_PASSWORD'
EOF
    # Update wpa_supplicant.conf
    if ! grep -q "ssid=\"$SSID\"" "$WPA_SUPPLICANT_CONF" 2>/dev/null; then
        sudo tee -a "$WPA_SUPPLICANT_CONF" > /dev/null << EOF
network={
    ssid="$SSID"
    psk="$WLAN_PASSWORD"
    key_mgmt=WPA-PSK
}
EOF
    fi
else
    echo "Configuring open network for $SSID..."
fi

# Ensure correct permissions
sudo chmod 600 "$IFCFG_FILE"
sudo chmod 600 "$WPA_SUPPLICANT_CONF" 2>/dev/null || true

# Ensure wicked and wpa_supplicant services are enabled
sudo systemctl enable wicked
sudo systemctl enable wpa_supplicant
sudo systemctl start wicked
sudo systemctl start wpa_supplicant
if ! systemctl is-active --quiet wicked; then
    echo "Error: wicked service failed to start"
    exit 1
fi
if ! systemctl is-active --quiet wpa_supplicant; then
    echo "Error: wpa_supplicant service failed to start"
    exit 1
fi
echo "wicked and wpa_supplicant services are running"

# Bring up the interface
echo "Bringing up interface $WLAN_IFACE for $SSID..."
sudo wicked ifup "$WLAN_IFACE" || {
    echo "Warning: Failed to connect to $SSID. Please check the password or network availability."
}

echo "Wi-Fi setup complete. Reboot or run 'sudo wicked ifup $WLAN_IFACE' to test connectivity."
