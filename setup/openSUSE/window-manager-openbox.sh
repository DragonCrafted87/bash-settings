#!/bin/bash

# Determine the directory of the script and the auxiliary directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")
AUX_DIR="$SCRIPT_DIR/window-manager-openbox"

# Function to set the system to boot into TTY
set_boot_to_tty() {
    sudo systemctl set-default multi-user.target
    echo "System set to boot into TTY."
}

# Function to install necessary packages
install_packages() {
    sudo zypper install -y openbox obconf wmctrl feh xterm pavucontrol curl
    echo "Installed Openbox, related packages, pavucontrol, and curl."
}

# Function to configure .xinitrc to start Openbox
configure_xinitrc() {
    echo "exec openbox-session" > ~/.xinitrc
    echo "Configured .xinitrc to start Openbox."
}

# Function to set up Openbox configuration files
setup_openbox_config() {
    mkdir -p ~/.config/openbox
    cp "$AUX_DIR/menu.xml" ~/.config/openbox/menu.xml
    if [ -f ~/.config/openbox/rc.xml ]; then
        cp ~/.config/openbox/rc.xml ~/.config/openbox/rc.xml.bak
        echo "Backed up existing rc.xml to rc.xml.bak."
    fi
    cp "$AUX_DIR/rc.xml" ~/.config/openbox/rc.xml
    echo "Copied menu.xml and rc.xml to ~/.config/openbox/"
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
        echo "Packman repository already exists."
    fi
}

# Function to install multimedia codecs from Packman
install_multimedia_codecs() {
    add_packman_repo
    echo "Refreshing repositories..."
    sudo zypper refresh
    echo "Switching system packages to Packman..."
    sudo zypper dup --allow-vendor-change --from packman
    echo "Installing multimedia codecs from Packman..."
    sudo zypper install --allow-vendor-change --from packman ffmpeg gstreamer-plugins-{good,bad,ugly,libav} libavcodec-full vlc-codecs
    echo "Installed multimedia codecs from Packman repository."
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
        sudo zypper install -y curl
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
        sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    else
        echo "Brave browser repository already exists."
    fi
    echo "Installing Brave browser..."
    sudo zypper install -y brave-browser
    echo "Installed Brave browser."
}

# Function to place the running-apps-pipe-menu.sh script
place_pipe_menu_script() {
    sudo cp "$AUX_DIR/running-apps-pipe-menu.sh" /usr/local/bin/
    sudo chmod +x /usr/local/bin/running-apps-pipe-menu.sh
    echo "Placed and set executable permissions for running-apps-pipe-menu.sh in /usr/local/bin/"
}

# Main function to orchestrate the setup
main() {
    set_boot_to_tty
    install_packages
    configure_xinitrc
    setup_openbox_config
    install_multimedia_codecs
    install_brave_browser
    place_pipe_menu_script
    echo "Openbox setup complete. To start Openbox, run 'startx' from the TTY."
}

# Execute the main function
main
