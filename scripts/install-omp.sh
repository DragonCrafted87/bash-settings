#!/usr/bin/env bash

install_dir=""

error() {
    printf '\x1b[31m%s\e[0m\n' "$1"
}

error_exit() {
    error "$1"
    exit 1
}

info() {
    printf '%s\n' "$1"
}

warn() {
    printf '⚠️  \x1b[33m%s\e[0m\n'  "$1"
}

help() {
    # Display Help
    echo "Installs Oh My Posh"
    echo
    echo "Syntax: install.sh [-h|d]"
    echo "options:"
    echo "h     Print this Help."
    echo "d     Specify the installation directory. Defaults to /usr/local/bin or the directory where oh-my-posh is installed."
    echo
}

while getopts ":hd:" option; do
   case $option in
      h) # display Help
         help
         exit;;
      d) # Enter a name
         install_dir=$OPTARG;;
     \?) # Invalid option
         echo "Invalid option command line option. Use -h for help."
         exit 1
   esac
done

SUPPORTED_TARGETS="linux-386 linux-amd64 linux-arm linux-arm64 darwin-amd64 darwin-arm64 windows-386.exe windows-amd64.exe windows-arm64.exe"

validate_dependency() {
    if ! command -v "$1" >/dev/null; then
        error_exit "$1 is required to install Oh My Posh. Please install $1 and try again."
    fi
}

validate_dependencies() {
    validate_dependency curl
    validate_dependency unzip
    validate_dependency realpath
    validate_dependency dirname
}

set_install_directory() {
    if [ -n "$install_dir" ]; then
        # expand directory
        install_dir="${install_dir/#\~/$HOME}"
        return 0
    fi

    # check if we have oh-my-posh installed, if so, use the executable directory
    # to install into and follow symlinks
    if command -v oh-my-posh >/dev/null; then
        posh_dir=$(command -v oh-my-posh)
        real_dir=$(realpath "$posh_dir")
        install_dir=$(dirname "$real_dir")
        info "Oh My Posh is already installed, updating existing installation in:"
        info "  ${install_dir}"
    else
        install_dir="/usr/local/bin"
    fi
}

validate_install_directory() {
    if [ ! -d "$install_dir" ]; then
        error_exit "Directory ${install_dir} does not exist, set a different directory and try again."
    fi

    # check if we can write to the install directory
    if [ ! -w "$install_dir" ]; then
        error "Cannot write to ${install_dir}. Please set a different directory and try again:"
        error_exit "bash \"${PATH_BASH_SETTINGS}/scripts/install-omp.sh\" -d ${install_dir}"
    fi

    # check if the directory is in the PATH
    good=$(
        IFS=:
        for path in $PATH; do
        if [ "${path%/}" = "${install_dir}" ]; then
            printf 1
            break
        fi
        done
    )

    if [ "${good}" != "1" ]; then
        warn "Installation directory ${install_dir} is not in your \$PATH"
    fi
}

install() {
    arch=$(detect_arch)
    platform=$(detect_platform)
    extension=$(detect_extension)
    target="${platform}-${arch}${extension}"

    good=$(
        IFS=" "
        for t in $SUPPORTED_TARGETS; do
        if [ "${t}" = "${target}" ]; then
            printf 1
            break
        fi
        done
    )

    if [ "${good}" != "1" ]; then
        error_exit "${arch} builds for ${platform} are not available for Oh My Posh"
    fi

    info
    info "Installing oh-my-posh for ${target} in ${install_dir}"

    executable=${install_dir}/oh-my-posh
    url=https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-${target}

    info "⬇️  Downloading oh-my-posh from ${url}"

    http_response=$(curl -s -f -L "$url" -o "$executable" -w "%{http_code}")

    if [ "$http_response" != "200" ] || [ ! -f "$executable" ]; then
        error "Unable to download executable at ${url}"
        error_exit "Please validate your curl, connection and/or proxy settings"
    fi

    chmod +x "$executable"

    info "🚀 Installation complete."
    info
    info "You can follow the instructions at https://ohmyposh.dev/docs/installation/prompt"
    info "to setup your shell to use oh-my-posh."

}

detect_arch() {
  arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

  case "${arch}" in
    x86_64) arch="amd64" ;;
    armv*) arch="arm" ;;
    arm64) arch="arm64" ;;
    aarch64) arch="arm64" ;;
    i686) arch="386" ;;
  esac

  if [ "${arch}" = "arm64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
    arch=arm
  fi

  printf '%s' "${arch}"
}


detect_platform() {
  platform="$(uname -s | awk '{print tolower($0)}')"

  case "${platform}" in
    linux) platform="linux" ;;
    darwin) platform="darwin" ;;
    win*|msys*|cygwin*|mingw*) platform="windows" ;;
  esac

  printf '%s' "${platform}"
}


detect_extension() {
  platform=$(detect_platform)
  extension=""

  case "${platform}" in
    linux) extension="" ;;
    darwin) extension="" ;;
    windows) extension=".exe" ;;
  esac

  printf '%s' "${extension}"
}

validate_dependencies
set_install_directory
validate_install_directory
install
