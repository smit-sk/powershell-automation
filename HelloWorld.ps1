# Load the JSON credentials from an environment variable
$creds = $env:AZURE_CREDENTIALS | ConvertFrom-Json

# Log in to Azure with the Service Principal credentials
$securePassword = ConvertTo-SecureString $creds.clientSecret -AsPlainText -Force
$psCredential = New-Object System.Management.Automation.PSCredential ($creds.clientId, $securePassword)
Connect-AzAccount -ServicePrincipal -Credential $psCredential -Tenant $creds.tenantId

# Set the subscription context to avoid the "No subscription found" error
Set-AzContext -SubscriptionId $creds.subscriptionId

# Your VM creation script
$resourceGroupName = "Project-07-RG"
$location = "canadacentral"
$vmName = "Powershell-VM"
$adminUsername = "azureuser"
$adminPassword = ConvertTo-SecureString "Smit@7008" -AsPlainText -Force

New-AzVm -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Name $vmName `
    -Credential (New-Object System.Management.Automation.PSCredential -ArgumentList $adminUsername, $adminPassword) `
    -Image "Ubuntu2204" `
    -PublicIpAddressName "$vmName-publicIP"
