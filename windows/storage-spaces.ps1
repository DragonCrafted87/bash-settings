exit

# https://wasteofserver.com/storage-spaces-with-parity-very-slow-writes-solved/

New-VirtualDisk -StoragePoolFriendlyName "Storage pool" -FriendlyName "FastParity" -NumberOfColumns 3 -Interleave 64KB -ResiliencySettingName Parity -UseMaximumSize
