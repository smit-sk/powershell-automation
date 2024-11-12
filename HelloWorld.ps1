
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

