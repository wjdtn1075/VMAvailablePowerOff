Prod by Jeongsoo.Kim@goodus.com
Updated 2023-04-06


## Importing Module
Get-Module -Name VMware.VimAutomation.Core
Get-Module -Name VMware.VumAutomation
Get-Module -Name VMware.VimAutomation.HorizonView

Write-Host "Import Module: VMware.VimAutomation.HorizonView"
Import-Module -Name VMware.VimAutomation.HorizonView

Get-Module -ListAvailable 'VMware.Hv.Helper' | Import-Module

Write-Host "Import Module: VMware.VimAutomation.Core"
Import-Module -Name VMware.VimAutomation.Core
Write-Host "Import Complete"

Write-Host "Import Module: VMware.Hv.Helper"
Import-Module -Name VMware.Hv.Helper
Write-Host "Import Complete"

## Getting HVDesktop Status (whether it is availabe or unavailabe)

## Horizon Connection Server info
$User = "horizonsvc"
$Password = "VMware1!"
##$poolname = "wind10-Dedi-Auto", "win10-dedi-pool2"
##$poolname = "wind10-Dedi-Auto", " "  # If you want to restart only one pool, you need to put null (" ") at the poolname variable.
$poolname = "win10-dedi-pool2", " "
$Domainadd = "kjs.nsx"

## vCenter info
$vcuser = "administrator@vsphere.local"
$vcpasswd = "VMware1!"

## Connect Horizon Connection Server
Write-Host "Connect to connection server"

$connSvr = Connect-HVServer -Server 'cs01' -User $User -Password $Password -Domain $Domainadd
$viewAPI = $connSvr.ExtensionData

## vCenter 접속

Write-Output "Connect to vCenter"
$viConn = Connect-VIServer -Server 'vc01.kjs.nsx' -User $vcuser -Password $vcpasswd
Write-Output "Connect to vCenter complete"

## Get pool info

for ($n=0 ; $n -lt $poolname.count ; $n++) {
	Write-Output "----------------------------------------------------"
	Write-Output "Shutdowning Available virtual machines in pool $($poolname[$n])"
	#$vmlist = Get-HVDesktop -Pool $pool
	$vmlist = Get-HVMachine -pool $poolname[$n] | select -expandproperty Base | Select Name, BasicState
	foreach ($vm in $vmlist) {
	if($vm.BasicState -eq 'CONNECTED')
	{
		$msg = [string]::Format("Connected VM   : {0}, Bypass", $vm.Name)
		Write-Host $msg -Foregroundcolor Gray
	}	
	else
	{
		$msg = [string]::Format("Available VM   : {0}, Shutdown Guest OS", $vm.Name)
		Write-Host $msg -Foregroundcolor Green
		Get-VM $vm.Name | Where {$_.PowerState -eq "PoweredOn"} | Shutdown-VMGuest -Confirm:$false
	}
	}
}

#>
# 연결 종
Disconnect-VIServer $viConn -Confirm:$false
Disconnect-HVServer $connSvr -Confirm:$false

## $pool.