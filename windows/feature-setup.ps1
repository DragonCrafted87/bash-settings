Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Online -NoRestart
Enable-WindowsOptionalFeature -FeatureName ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure -Online -NoRestart
Restart-Computer
