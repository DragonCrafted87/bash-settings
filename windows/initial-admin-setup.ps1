if (-not ( [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") ))
{
    Write-Output "Run this Script with regular user permissions not Admin."
    Exit
}

winget install "Microsoft.WindowsTerminal"
winget install "Git.Git"

[System.Environment]::SetEnvironmentVariable("CHROME_EXECUTABLE",'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe','User')
[System.Environment]::SetEnvironmentVariable("HOME",'D:\git-home','User')
[System.Environment]::SetEnvironmentVariable("JAVA_HOME",'D:\git-home\purple-poultry-pirate-productions\build-tools\java\jdk-17.0.9-full','User')

$Env:Path = 'D:\git-home\ffmpeg\bin;'
$Env:Path += 'D:\git-home\bin;'
$Env:Path += 'C:\Users\gudem\AppData\Local\Programs\Python\Python311\Scripts;'
$Env:Path += 'C:\Users\gudem\AppData\Local\Programs\Python\Python311;'
$Env:Path += 'C:\Users\gudem\AppData\Local\Programs\Python\Launcher;'
$Env:Path += 'C:\Users\gudem\AppData\Local\Microsoft\WindowsApps;'
$Env:Path += 'C:\Users\gudem\AppData\Local\Programs\Microsoft VS Code\bin;'
$Env:Path += 'D:\git-home\purple-poultry-pirate-productions\build-tools\flutter\bin;'
$Env:Path += 'D:\git-home\purple-poultry-pirate-productions\build-tools\android_sdk\cmdline-tools\latest\bin;'
$Env:Path += 'C:\Users\gudem\AppData\Local\Programs\Microsoft VS Code\bin;'
$Env:Path += 'C:\Users\gudem\AppData\Roaming\npm;'
$Env:Path += 'C:\Users\gudem\AppData\Local\Programs\Ollama;'
$Env:Path += 'C:\Program Files\Racket;'
$Env:Path += 'c:\users\gudem\.local\bin;'
$Env:Path += 'c:\users\gudem\appdata\roaming\python\python311\scripts;'

[System.Environment]::SetEnvironmentVariable("Path",$Env:Path,'User')

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousUid" -Value "1000"  -PropertyType "dword"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousGid" -Value "1000"  -PropertyType "dword"

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
Enable-WindowsOptionalFeature -FeatureName ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure -Online -NoRestart

Restart-Computer
