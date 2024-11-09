# Load the JSON credentials from an environment variable
$creds = $env:AZURE_CREDENTIALS | ConvertFrom-Json

# Log in to Azure with the Service Principal credentials
$securePassword = ConvertTo-SecureString $creds.clientSecret -AsPlainText -Force
$psCredential = New-Object System.Management.Automation.PSCredential ($creds.clientId, $securePassword)
Connect-AzAccount -ServicePrincipal -Credential $psCredential -Tenant $creds.tenantId

# Set the subscription context to avoid the "No subscription found" error
Set-AzContext -SubscriptionId $creds.subscriptionId


# Your VM creation script
$resourceGroupName = "Project-07-RG-01"
$location = "canadacentral"
$vmName = "Powershell-VM"
$adminUsername = "azureuser"
$containerName = "my-first-blob-container"
$adminPassword = ConvertTo-SecureString "Smit@7008" -AsPlainText -Force
$storageAccountName = "sstorage${vmName}".ToLower() -replace '-', '' 

# Create a Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

# Create Storage Account
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location $location `
    -SkuName Standard_LRS `
    -Kind StorageV2

$container = $storageAccount.Context 
New-AzStorageContainer -Name $containerName -Context $container 

New-AzVm -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Name $vmName `
    -Credential (New-Object System.Management.Automation.PSCredential -ArgumentList $adminUsername, $adminPassword) `
    -Image "Ubuntu2204" `
    -VirtualNetworkName 'myVnet' `
    -SubnetName 'mySubnet' `
    -SecurityGroupName 'myNetworkSecurityGroup' `
    -PublicIpAddressName 'myPublicIpAddress' `
    -OpenPorts 80,3389

