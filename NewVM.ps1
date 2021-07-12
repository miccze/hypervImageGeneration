#nazwa: Nowa_WM_z_VHDX
#cel:Postawienie nowej maszyny wirtualnej na podstawie dostarczonego obrazu przez użytkownika
#Autor: Michał Czech
#Data: 04.09.2017


#$TARGETDIR = Read-Host -Prompt 'Input directory for new VM'
#$VHDXpath = Read-Host -Prompt 'Input directory for VHDX image'
#$NanoName = Read-Host -Prompt 'Input name of new VM'
#$vSwitchName = Read-host -Prompt 'Input name of Virtual Switch'

$TARGETDIR = "D:\VirtualMachines3\"
#$VHDXpath = "\\volt\czechm\praca\NanoVMs\NanoIem07\VHDX\NanoIem07.vhdx"
$VHDXpath = "D:\VirtualMachines3\Justyna-Nano\VHDX\Justyna-nano.vhdx"
$NanoName = "Justyna-nano"
$vSwitchName = "ExtSwitch"



$VMpath = $TARGETDIR+"\"+$NanoName+"\VM" 


Function Test-IsNetworkLocation {
	<#
		.SYNOPSIS
			Determines whether or not a given path is a network location or a local drive.
		.DESCRIPTION
			Function to determine whether or not a specified path is a local path, a UNC path,
			or a mapped network drive.
		.PARAMETER Path
			The path that we need to figure stuff out about,
	#>

	[CmdletBinding()]
	param(
		[Parameter(ValueFromPipeLine = $true)]
		[string]
		[ValidateNotNullOrEmpty()]
		$Path
	)

	$result = $false

	if ([bool]([URI]$Path).IsUNC)
	{
		$result = $true
	}
	else
	{
		$driveInfo = [IO.DriveInfo]((Resolve-Path $Path).Path)

		if ($driveInfo.DriveType -eq "Network")
		{
			$result = $true
		}
	}

	return $result
}

#Sprawdzanie czy ścieżka do VHDX jest lokalna czy sieciowa. W przypadku sieciowej, konieczne jest przekopiowanie obrazu loklanie. 
if (Test-IsNetworkLocation $VHDXpath) {
	$VHDX = Split-path $VHDXpath -Leaf
	$CopyDir = Join-Path -path $VMpath -ChildPath "VHDX"
	New-item $CopyDir -ItemType Directory -ErrorAction SilentlyContinue
	Copy-Item -Path $VHDXpath -Destination $CopyDir -Force
	$VHDXLocalPath = Join-Path -Path $CopyDir -ChildPath $VHDX
	#Tworzenie wirtualnej maszyny z obrazu przekopiowanego lokalnie. 
	New-VM -Name $NanoName -MemoryStartupBytes 1GB -BootDevice VHD -VHDPath $VHDXLocalPath -Path $VMpath -Generation 2 -SwitchName $vSwitchName
} else {
	New-VM -Name $NanoName -MemoryStartupBytes 1GB -BootDevice VHD -VHDPath $VHDXpath -Path $VMpath -Generation 2 -SwitchName $vSwitchName
}


Get-VM

