exit

# https://wasteofserver.com/storage-spaces-with-parity-very-slow-writes-solved/

# setup win 10 workstation
slmgr /ipk DXG7C-N36C4-C4HTG-X4T3X-2YV77

New-VirtualDisk `
    -StoragePoolFriendlyName "Storage pool" `
    -FriendlyName "Storage 8x16" `
    -NumberOfColumns 8 `
    -Interleave 16KB `
    -ResiliencySettingName Parity `
    -PhysicalDiskRedundancy 2 `
    -ProvisioningType Thin `
    -Size 10TB

Get-VirtualDisk "Storage 8x16" | `
    Get-Disk | `
        Initialize-Disk -PassThru | `
            New-Partition `
                -AssignDriveLetter `
                -UseMaximumSize

Format-Volume `
    -DriveLetter D `
    -FileSystem REFS `
    -AllocationUnitSize 65536









New-VirtualDisk `
    -StoragePoolFriendlyName "Storage pool" `
    -FriendlyName "OneDrive 8x16" `
    -NumberOfColumns 8 `
    -Interleave 16KB `
    -ResiliencySettingName Parity `
    -PhysicalDiskRedundancy 2 `
    -ProvisioningType Thin `
    -Size 50GB

Get-VirtualDisk "OneDrive 8x16" | `
    Get-Disk | `
        Initialize-Disk -PassThru | `
            New-Partition `
                -UseMaximumSize

Format-Volume `
    -DriveLetter E `
    -FileSystem NTFS `
    -AllocationUnitSize 131072
