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
    sudo zypper install -y openbox obconf wmctrl feh xterm
    echo "Installed Openbox and related packages."
}

# Function to configure .xinitrc to start Openbox
configure_xinitrc() {
    echo "exec openbox-session" > ~/.xinitrc
    echo "Configured .xinitrc to start Openbox."
}

# Function to set up the Openbox menu
setup_openbox_menu() {
    mkdir -p ~/.config/openbox
    cp "$AUX_DIR/menu.xml" ~/.config/openbox/menu.xml
    echo "Copied menu.xml to ~/.config/openbox/"
}

# Function to install multimedia codecs from Packman
install_multimedia_codecs() {
    sudo zypper addrepo -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_15.6/' packman
    sudo zypper refresh
    sudo zypper install --allow-vendor-change ffmpeg gstreamer-plugins-{good,bad,ugly,libav} libavcodec-full vlc-codecs
    echo "Installed multimedia codecs from Packman repository."
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
    setup_openbox_menu
    install_multimedia_codecs
    place_pipe_menu_script
    echo "Openbox setup complete. To start Openbox, run 'startx' from the TTY."
}

# Execute the main function
main
