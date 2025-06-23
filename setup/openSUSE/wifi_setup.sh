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

# Ensure required packages are installed
for pkg in wicked wireless-tools wpa_supplicant; do
    echo "Ensuring $pkg is installed..."
    sudo zypper install -y "$pkg" || {
        echo "Error: Failed to install $pkg. Please install it manually."
        exit 1
    }
done

# Check for wireless interface
WLAN_IFACE=$(ip link | grep -E '^[0-9]+: wlan' | awk '{print $2}' | sed 's/:$//' | head -n 1)
if [ -z "$WLAN_IFACE" ]; then
    echo "Error: No wireless interface found. Please ensure your wireless adapter is working."
    echo "Run 'rfkill list' to check for blocks and 'rfkill unblock all' if needed."
    exit 1
fi
echo "Wireless interface found: $WLAN_IFACE"

# Bring up the wireless interface and verify state
echo "Bringing up wireless interface $WLAN_IFACE..."
sudo ip link set "$WLAN_IFACE" up
sleep 5  # Increased sleep to ensure interface readiness

# Check interface state
IFACE_STATE=$(ip link show "$WLAN_IFACE" | grep -o "state [A-Z]*" | awk '{print $2}')
echo "Interface $WLAN_IFACE state: $IFACE_STATE"
if [ "$IFACE_STATE" = "DOWN" ]; then
    echo "Warning: Interface $WLAN_IFACE is still DOWN. Attempting to resolve..."
    sudo rfkill unblock all
    sudo ip link set "$WLAN_IFACE" up
    sleep 5
    IFACE_STATE=$(ip link show "$WLAN_IFACE" | grep -o "state [A-Z]*" | awk '{print $2}')
    echo "Updated interface state: $IFACE_STATE"
    if [ "$IFACE_STATE" = "DOWN" ]; then
        echo "Error: Failed to bring $WLAN_IFACE up. Check hardware or driver issues."
        exit 1
    fi
fi

# Scan for available Wi-Fi networks using iwlist
echo "Scanning for available Wi-Fi networks with iwlist..."
SCAN_OUTPUT=$(sudo iwlist "$WLAN_IFACE" scan 2>&1)
SCAN_STATUS=$?
echo "iwlist scan status code: $SCAN_STATUS"
echo "iwlist scan output:"
echo "$SCAN_OUTPUT"
if [ $SCAN_STATUS -ne 0 ]; then
    echo "Error: iwlist scan failed. See output above."
    # Fallback to wpa_cli
    echo "Attempting scan with wpa_cli..."
    sudo wpa_supplicant -B -i "$WLAN_IFACE" -c /etc/wpa_supplicant.conf -P /var/run/wpa_supplicant-$WLAN_IFACE.pid 2>/dev/null
    sleep 2
    WPA_SCAN_OUTPUT=$(sudo wpa_cli -i "$WLAN_IFACE" scan && sudo wpa_cli -i "$WLAN_IFACE" scan_results 2>&1)
    WPA_STATUS=$?
    echo "wpa_cli scan status code: $WPA_STATUS"
    echo "wpa_cli scan output:"
    echo "$WPA_SCAN_OUTPUT"
    if [ $WPA_STATUS -ne 0 ]; then
        echo "Error: wpa_cli scan failed. See output above."
        exit 1
    fi
    # Parse SSIDs from wpa_cli output
    SSIDS=$(echo "$WPA_SCAN_OUTPUT" | awk 'NR>2 {print $NF}' | sort | uniq)
else
    # Parse SSIDs from iwlist output
    SSIDS=$(echo "$SCAN_OUTPUT" | grep 'ESSID:' | sed 's/.*ESSID:"\([^"]*\)"/\1/' | sort | uniq)
fi

if [ -z "$SSIDS" ]; then
    echo "Error: No Wi-Fi networks found. Ensure the adapter is active and networks are in range."
    exit 1
fi

# Display available SSIDs
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
    echo "Warning: Failed to connect to $SSID. Check password or network availability."
}

echo "Wi-Fi setup complete. Reboot or run 'sudo wicked ifup $WLAN_IFACE' to test connectivity."
