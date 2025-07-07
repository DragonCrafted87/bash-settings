#!/bin/bash
# Subcontrol script to set up Openbox window manager on openSUSE Leap 15.6
# Idempotent: checks for existing packages, configurations, and repositories
# Run with sudo from setup/openSUSE/window-manager-openbox/ directory or via main script

set -e

# Determine the directory of the script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Function to set the system to boot into TTY
set_boot_to_tty() {
    if ! systemctl get-default | grep -q "multi-user.target"; then
        echo "Setting system to boot into TTY..."
        sudo systemctl set-default multi-user.target
    else
        echo "System already set to boot into TTY"
    fi
}

# Function to install necessary packages
install_packages() {
    echo "Checking Openbox and dependencies..."
    PACKAGES="openbox obconf wmctrl feh xterm pavucontrol curl mpv python3 python3-pip python3-qt5"
    for PKG in $PACKAGES; do
        if ! rpm -q "$PKG" >/dev/null 2>&1; then
            echo "Installing $PKG..."
            sudo zypper install -y "$PKG"
        else
            echo "$PKG is already installed"
        fi
    done
}

# Function to install jellyfin-mpv-shim via pip
install_jellyfin_mpv_shim() {
    echo "Checking jellyfin-mpv-shim..."
    if ! pip3 show jellyfin-mpv-shim >/dev/null 2>&1; then
        echo "Installing jellyfin-mpv-shim via pip..."
        sudo pip3 install --upgrade jellyfin-mpv-shim
    else
        echo "jellyfin-mpv-shim is already installed"
    fi
}

# Function to configure .xinitrc to start Openbox
configure_xinitrc() {
    if [ ! -f ~/.xinitrc ] || ! grep -q "exec openbox-session" ~/.xinitrc; then
        echo "Configuring .xinitrc to start Openbox..."
        echo "exec openbox-session" > ~/.xinitrc
    else
        echo ".xinitrc already configured for Openbox"
    fi
}

# Function to set up Openbox configuration files
setup_openbox_config() {
    mkdir -p ~/.config/openbox
    for FILE in menu.xml rc.xml autostart; do
        SRC="$SCRIPT_DIR/$FILE"
        DEST=~/.config/openbox/$FILE
        if [ -f "$SRC" ]; then
            if [ -f "$DEST" ] && cmp -s "$SRC" "$DEST"; then
                echo "$DEST is already up to date"
            else
                echo "Copying $SRC to $DEST..."
                cp "$SRC" "$DEST"
            fi
        else
            echo "Warning: $SRC not found"
        fi
    done
}

# Function to check if Packman repository exists
check_packman_repo() {
    zypper lr | grep -q "packman"
    return $?
}

# Function to add Packman repository if it doesn't exist
add_packman_repo() {
    if ! check_packman_repo; then
        echo "Adding Packman repository..."
        sudo zypper addrepo -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_15.6/' packman
    else
        echo "Packman repository already exists"
    fi
}

# Function to install multimedia codecs from Packman
install_multimedia_codecs() {
    add_packman_repo
    echo "Refreshing repositories..."
    sudo zypper refresh
    echo "Checking multimedia codecs..."
    PACKAGES="ffmpeg gstreamer-plugins-good gstreamer-plugins-bad gstreamer-plugins-ugly gstreamer-plugins-libav libavcodec-full vlc-codecs"
    for PKG in $PACKAGES; do
        if ! rpm -q "$PKG" >/dev/null 2>&1; then
            echo "Installing $PKG from Packman..."
            sudo zypper install --allow-vendor-change --from packman "$PKG"
        else
            echo "$PKG is already installed"
        fi
    done
}

# Function to check if Brave repository exists
check_brave_repo() {
    zypper lr | grep -q "brave-browser"
    return $?
}

# Function to install Brave browser
install_brave_browser() {
    if ! check_brave_repo; then
        echo "Adding Brave browser repository..."
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
        sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    else
        echo "Brave browser repository already exists"
    fi
    echo "Checking Brave browser..."
    if ! rpm -q brave-browser >/dev/null 2>&1; then
        echo "Installing Brave browser..."
        sudo zypper install -y brave-browser
    else
        echo "Brave browser is already installed"
    fi
}

# Function to place the running-apps-pipe-menu.sh script
place_pipe_menu_script() {
    SRC="$SCRIPT_DIR/running-apps-pipe-menu.sh"
    DEST="/usr/local/bin/running-apps-pipe-menu.sh"
    if [ -f "$SRC" ]; then
        if [ -f "$DEST" ] && cmp -s "$SRC" "$DEST"; then
            echo "$DEST is already up to date"
        else
            echo "Copying $SRC to $DEST..."
            sudo cp "$SRC" "$DEST"
            sudo chmod +x "$DEST"
        fi
    else
        echo "Warning: $SRC not found"
    fi
}

# Main function to orchestrate the setup
main() {
    set_boot_to_tty
    install_packages
    install_jellyfin_mpv_shim
    configure_xinitrc
    setup_openbox_config
    install_multimedia_codecs
    install_brave_browser
    place_pipe_menu_script
}

# Execute the main function
main
echo "Openbox setup complete."
exit 0
