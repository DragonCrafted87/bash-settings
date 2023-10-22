New-SmbMapping -LocalPath 'Z:' -RemotePath '\\192.168.8.2\Backups'
New-SmbMapping -LocalPath 'U:' -RemotePath '\\192.168.8.2\Unrestricted'
New-SmbMapping -LocalPath 'T:' -RemotePath '\\192.168.8.2\Greyhole Trash'
New-SmbMapping -LocalPath 'S:' -RemotePath '\\192.168.8.2\Storage'
