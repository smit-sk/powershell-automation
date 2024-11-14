# Variables
$resourceGroup = "Project-07-RG-01"         # Name of the resource group
$location = "canadacentral"                 # Azure region
$vmName = "MyVM01"                          # Virtual Machine name
$vmSize = "Standard_B1s"                    # VM size
$vnetName = "P7-01-vnet"                       # Virtual Network name
$subnetName = "default"                     # Subnet name
$adminUsername = "azureuser"                # Admin username for VM login
$adminPassword = ConvertTo-SecureString "qwer1234QWER" -AsPlainText -Force  # Admin password (make sure to handle this securely)

# Logging function for tracking script progress
function Log-Message {
    param (
        [string]$message
    )
    Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") : $message"
}

# Start of script log
Log-Message "Starting Azure VM provisioning process."

New-AzResourceGroup -Name $resourceGroup -Location $location -Force
Log-Message "$resourceGroup created successfully."

# Get existing Virtual Network and Subnet
Log-Message "Retrieving Virtual Network and Subnet."
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location -Name $vnetName -AddressPrefix "10.0.0.0/16"
$subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet -AddressPrefix "10.0.2.0/24"
$vnet | Set-AzVirtualNetwork

$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroup -Name $vnetName
$subnetId = $vnet.Subnets[0].Id 

# Create Public IP Address
Log-Message "Creating a Static Public IP Address."
$pip = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Location $location -Name "MyPublicIP" -AllocationMethod Static

# Create Network Security Group and add RDP and HTTP rules
Log-Message "Creating Network Security Group with RDP and HTTP access rules."
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location -Name "MyNSG"

# Allow RDP rule
$nsgRuleRdp = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Protocol "Tcp" `
    -Direction "Inbound" -Priority 1000 -SourceAddressPrefix "*" `
    -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "3389" `
    -Access "Allow"
$nsg.SecurityRules.Add($nsgRuleRdp)

# Allow HTTP rule
$nsgRuleHttp = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Protocol "Tcp" `
    -Direction "Inbound" -Priority 1001 -SourceAddressPrefix "*" `
    -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "80" `
    -Access "Allow"
$nsg.SecurityRules.Add($nsgRuleHttp)

# Apply the NSG configuration
$nsg | Set-AzNetworkSecurityGroup


# Create Network Interface (NIC) and associate with NSG and Public IP
Log-Message "Creating Network Interface and associating with NSG and Public IP."


Write-Output "Subnet ID: $subnetId"

if (-not [string]::IsNullOrEmpty($subnetId)) {

    $nic = New-AzNetworkInterface -Name "MyNic" -ResourceGroupName $resourceGroup -Location $location `
    -SubnetId $subnetId -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

}else {
    Write-Output "Failed to retrive subnet Id"
}

# Configure the VM with OS, image, and NIC
Log-Message "Configuring the VM."
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize | `
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)) | `
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" | `
    Add-AzVMNetworkInterface -Id $nic.Id

# Deploy the VM
Log-Message "Initiating VM creation."
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

# End of script log
Log-Message "Azure VM provisioning process completed."
