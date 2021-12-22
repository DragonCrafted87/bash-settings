[Environment]::SetEnvironmentVariable(
    "Path",
    "D:\Applications\Local Binaries;" + [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User),
    [EnvironmentVariableTarget]::User)

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";D:\Applications\Racket",
    [EnvironmentVariableTarget]::User)

[Environment]::SetEnvironmentVariable(
    "HOME",
    "D:\git-home",
    [EnvironmentVariableTarget]::User)

[Environment]::SetEnvironmentVariable(
    "OneDrive",
    "D:\OneDrive",
    [EnvironmentVariableTarget]::User)

[Environment]::SetEnvironmentVariable(
    "OneDriveConsumer",
    "D:\OneDrive",
    [EnvironmentVariableTarget]::User)

# Save the computers Taskbar
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Desktop" "D:\git-home\bash-settings\windows\taskbar-laptop.reg"

reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Desktop" "D:\git-home\bash-settings\windows\taskbar-desktop.reg"

# Remove
Remove-ItemProperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Desktop -Name TaskbarWinXP
reg import "D:\git-home\bash-settings\windows\taskbar-laptop.reg"
taskkill /f /im explorer.exe
start explorer.exe

Remove-ItemProperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Desktop -Name TaskbarWinXP
reg import "D:\git-home\bash-settings\windows\taskbar-desktop.reg"
taskkill /f /im explorer.exe
start explorer.exe



pacman -Syu
pacman -Su
pacman -S \
    --needed \
    base-devel \
    python-pip \
    git \
    mingw-w64-clang-x86_64-boost\
    mingw-w64-clang-x86_64-cmake \
    mingw-w64-clang-x86_64-cppcheck \
    mingw-w64-clang-x86_64-ninja \
    mingw-w64-clang-x86_64-toolchain \
    mingw-w64-clang-x86_64-ffmpeg \

pip install pre-commit
pacman -S msys2-devel
pacman -S clang
