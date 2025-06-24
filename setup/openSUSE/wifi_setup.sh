#!/bin/bash

# Script to set up WLAN to autoconnect on openSUSE Leap 15.6 using wicked
# Run as the 'dragon' user with sudo privileges

# Variables
NETWORK_CONFIG_DIR="/etc/sysconfig/network"
WPA_SUPPLICANT_CONF="/etc/wpa_supplicant.conf"
WLAN_IFACE=$(ip link | grep -E '^[0-9]+: wlan' | awk '{print $2}' | sed 's/:$//' | head -n 1)
IFCFG_FILE="$NETWORK_CONFIG_DIR/ifcfg-$WLAN_IFACE"

# Check if running as the 'dragon' user and not root
if [ "$(id -u)" -eq 0 ] || [ "$(whoami)" != "dragon" ]; then
    echo "Error: This script must be run as the 'dragon' user, not as root or another user."
    exit 1
fi

# Check if wireless interface is detected
if [ -z "$WLAN_IFACE" ]; then
    echo "Error: No wireless interface found."
    exit 1
fi
echo "Wireless interface found: $WLAN_IFACE"

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

# Stop wpa_supplicant and reset the interface
echo "Stopping wpa_supplicant and resetting $WLAN_IFACE..."
sudo systemctl stop wpa_supplicant
sudo killall wpa_supplicant 2>/dev/null  # Forcefully terminate any lingering instances
sudo ip link set "$WLAN_IFACE" down
sleep 2  # Wait for the interface to settle

# Bring up the wireless interface
echo "Bringing up wireless interface $WLAN_IFACE..."
sudo ip link set "$WLAN_IFACE" up
sleep 5  # Wait for the interface to initialize

# Scan for available Wi-Fi networks using iwlist
echo "Scanning for available Wi-Fi networks with iwlist..."
SCAN_OUTPUT=$(sudo iwlist "$WLAN_IFACE" scan 2>&1)
SCAN_STATUS=$?
echo "iwlist scan status code: $SCAN_STATUS"
echo "iwlist scan output:"
echo "$SCAN_OUTPUT"
if [ $SCAN_STATUS -ne 0 ]; then
    echo "Error: iwlist scan failed. See output above."
    exit 1
fi

# Extract SSIDs into an array
mapfile -t SSIDS < <(echo "$SCAN_OUTPUT" | grep 'ESSID:"' | sed 's/.*ESSID:"\([^"]*\)"/\1/' | grep -v '^$' | sort | uniq)

# Check if any SSIDs were found
if [ ${#SSIDS[@]} -eq 0 ]; then
    echo "Error: No Wi-Fi networks found. Ensure the adapter is active and networks are in range."
    exit 1
fi

# Display available SSIDs and prompt for selection
echo "Available Wi-Fi networks:"
for i in "${!SSIDS[@]}"; do
    echo "$((i+1))) ${SSIDS[$i]}"
done
echo "q) Quit"
read -p "Select an SSID by number or 'q' to quit: " choice
if [ "$choice" = "q" ]; then
    echo "Exiting without configuring Wi-Fi."
    exit 0
elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#SSIDS[@]} ]; then
    SSID="${SSIDS[$((choice-1))]}"
    echo "Selected SSID: $SSID"
else
    echo "Invalid selection."
    exit 1
fi

# Prompt for Wi-Fi password
read -sp "Enter Wi-Fi password for $SSID (leave blank for open network): " WLAN_PASSWORD
echo

# Write interface configuration with double quotes for SSID
echo "Creating or updating configuration for $SSID..."
sudo tee "$IFCFG_FILE" > /dev/null << EOF
NAME="$WLAN_IFACE"
BOOTPROTO='dhcp'
STARTMODE='auto'
WIRELESS='yes'
WIRELESS_ESSID="$SSID"
WIRELESS_MODE='Managed'
EOF

# Configure WPA-PSK if password provided, with double quotes for password
if [ -n "$WLAN_PASSWORD" ]; then
    echo "Configuring WPA-PSK for $SSID..."
    sudo tee -a "$IFCFG_FILE" > /dev/null << EOF
WIRELESS_AUTH_MODE='psk'
WIRELESS_WPA_PSK="$WLAN_PASSWORD"
EOF
fi

# Ensure correct permissions
sudo chmod 600 "$IFCFG_FILE"

# Ensure wicked and wpa_supplicant services are enabled and started
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

# Bring up the interface using the interface name, not the SSID
echo "Bringing up interface $WLAN_IFACE..."
sudo wicked ifup "$WLAN_IFACE" || {
    echo "Warning: Failed to connect to $SSID. Please check the password or network availability."
}

echo "Wi-Fi setup complete. Reboot or run 'sudo wicked ifup $WLAN_IFACE' to test connectivity."
