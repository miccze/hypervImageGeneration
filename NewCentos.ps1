<#
Skrypt do stworzenia wirtualnej maszyny Linuxowej w dystrybucji CentOS, za pomocą Hyper-V. SecureBoot włączony, 2 wirtualne procesory, 
#>

$VMName = "CentOSVM1"
$VMPath = "D:\VIrtual Machines\Linux\CentOSVM1"
$VHDXPath = "D:\VIrtual Machines\Linux\CentOSVM1\VHDX\CentOSVM1.vhdx"
$VHDXSizeBytes = 12GB
$ISOPath = "D:\Linux_iso\CentOS-7-x86_64-Everything-1804\CentOS-7-x86_64-Everything-1804.iso"
$VMSwitchName = "ExtSwitch"
$MaximumMemory = 2GB
$MinimumMemory = 256MB
$StartupMemory = 512MB

$VM = New-VM -Name $VMName -MemoryStartupBytes $StartupMemory -SwitchName $VMSwitchName -Path $VMPath -Generation 2 -NoVHD
Set-VMMemory -VM $VM -DynamicMemoryEnabled $true -MinimumBytes $MinimumMemory -MaximumBytes $MaximumMemory
Set-VMProcessor -VM $VM -Count 2
Start-VM -VM $VM
Stop-VM -VM $VM -Force
New-VHD -Path $VHDXPath -SizeBytes $VHDXSizeBytes -Dynamic -BlockSizeBytes 1MB
$VMVHD = Add-VMHardDiskDrive -VM $VM -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0 -Path $VHDXPath -Passthru
$VMDVDDrive = Add-VMDvdDrive -VM $VM -ControllerNumber 0 -ControllerLocation 1 -Passthru
$VMNetAdapter = Get-VMNetworkAdapter -VM $VM
Set-VMNetworkAdapter -VMNetworkAdapter $VMNetAdapter -StaticMacAddress ($VMNetAdapter.MacAddress)
Set-VMFirmware -VM $VM -BootOrder $VMDVDDrive, $VMVHD, $VMNetAdapter -EnableSecureBoot On -SecureBootTemplate 'MicrosoftUEFICertificateAuthority'
Set-VMDvdDrive -VMDvdDrive $VMDVDDrive -Path $ISOPath
