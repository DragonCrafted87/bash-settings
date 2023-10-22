New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousUid" -Value "1000"  -PropertyType "dword"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousGid" -Value "1000"  -PropertyType "dword"

net stop nfsclnt
net stop nfsrdr
net start nfsrdr
net start nfsclnt

Remove-Item -Path Alias:mount -ErrorAction Ignore

umount.exe -f -a
mount.exe 192.168.0.1:/srv/data y:
