# Load the JSON credentials from an environment variable
$creds = $env:AZURE_CREDENTIALS | ConvertFrom-Json

# Log in to Azure with the Service Principal credentials
$securePassword = ConvertTo-SecureString $creds.clientSecret -AsPlainText -Force
$psCredential = New-Object System.Management.Automation.PSCredential ($creds.clientId, $securePassword)
Connect-AzAccount -ServicePrincipal -Credential $psCredential -Tenant $creds.tenantId

# Create a Resource group if it doesn't exist 
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

# Set the subscription context to avoid the "No subscription found" error
Set-AzContext -SubscriptionId $creds.subscriptionId

# Your VM creation script
$resourceGroupName = "Project-07-RG"
$location = "canadacentral"
$vmName = "Powershell-VM"
$adminUsername = "azureuser"
$adminPassword = ConvertTo-SecureString "Smit@7008" -AsPlainText -Force
$storageAccountName = "storage${vmName}".ToLower() -replace '-', '' 

# Create Storage Account
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location $location `
    -SkuName Standard_LRS `
    -Kind StorageV2

$container = $storageAccount.Context 
New-AzStorageContainer -Name $containerName -Context $container -Permission Blob

$subnet = New-AzVirtualNetworkSubnetConfig -Name "default" -AddressPrefix "20.0.1.0/24"

$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "$vmName-Vnet" -AddressPrefix "20.0.0.0/16" -Subnet $subnet

New-AzVm -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Name $vmName `
    -Credential (New-Object System.Management.Automation.PSCredential -ArgumentList $adminUsername, $adminPassword) `
    -Image "Ubuntu2204" `
    -PublicIpAddressName "$vmName-publicIP"
    -Vnet $vnet 

