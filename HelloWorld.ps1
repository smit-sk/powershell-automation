$resourceGroupName = "Project-07-RG"
$location = "canadacentral"
$vmName = "Powershell-VM"
$adminUsername = "azureuser"
$adminPassword = ConvertTo-SecureString "Smit@7008" -AsPlainText -Force

# Specify your subscription ID here
$subscriptionId = "e618a55d-e5af-4210-96d7-212947f8a0af"

# Set the subscription context
Set-AzContext -SubscriptionId $subscriptionId


New-AzVm -ResourceGroupName $resourceGroupName `
	-Location $location `
	-Name $vmName `
	-Credential (New-Object System.Management.Automation.PSCredential -ArgumentList $adminUsername, $adminPassword) `
	-Image "Ubuntu2204" `
	-PublicIpAddressName "$vmName-publicIP"

