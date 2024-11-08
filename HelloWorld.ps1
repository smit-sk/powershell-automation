$resourceGroupName = "Project-07-RG"
$location = "canadacentral"
$vmName = "Powershell-VM"
$adminUsername = "azureuser"
$adminPassword = ConvertTo-SecureString "Smit@7008" -AsPlainText -Force

New-AzVm -ResourceGroupName $resourceGroupName `
	-Location $location `
	-Name $vmName `
	-Credential (New-Object System.Management.Automation.PSCredential - ArgumentList $adminUsername, $adminPassword) `
	-Image "Ubuntu2022"
	-PublicIpAddressName "$vmName-publicIP"

