
if ( [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") )
{
    Write-Output "Run this Script with regular user permissions not Admin."
    Exit
}

New-PSDrive -Name "O" -PSProvider "FileSystem" -Root '\\calligraphy-wyrm.stealthdragonland.net\Dragon-OneDrive' -Persist
New-PSDrive -Name "S" -PSProvider "FileSystem" -Root '\\calligraphy-wyrm.stealthdragonland.net\Storage' -Persist
New-PSDrive -Name "U" -PSProvider "FileSystem" -Root '\\calligraphy-wyrm.stealthdragonland.net\Unrestricted' -Persist
New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root '\\calligraphy-wyrm.stealthdragonland.net\Backups' -Persist
New-PSDrive -Name "Y" -PSProvider "FileSystem" -Root '\\castellan.stealthdragonland.net\srv\data' -Persist
