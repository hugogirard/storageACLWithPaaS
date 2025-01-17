using 'main.bicep'

param hubResourceGroupName = 'rg-hub-ase'

param hubVnetAddressPrefix = '10.0.0.0/16'

param subnetFirewalladdressPrefix = '10.0.1.0/24'

param subnetJumpboxaddressPrefix = '10.0.3.0/28'

param location = 'canadacentral'

param spokeResourceGroupName = 'rg-spoke-ase'

param subnetASEAddressPrefix = '10.1.0.0/16'

param subnetPEAddressPrefix = '10.1.1.0/24'

param vnetASEAddressPrefix = '10.1.2.0/24'
