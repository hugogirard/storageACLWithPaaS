using 'main.bicep'

param hubResourceGroupName = 'rg-hub-ase'

param hubVnetAddressPrefix = '10.0.0.0/16'

param subnetFirewalladdressPrefix = '10.0.1.0/26'

param subnetManagementFirewalladdressPrefix = '10.0.2.0/24'

param subnetJumpboxaddressPrefix = '10.0.3.0/28'

param location = 'canadacentral'

param spokeResourceGroupName = 'rg-spoke-ase'

param subnetASEAddressPrefix = '11.0.1.0/24'

param subnetPEAddressPrefix = '11.0.2.0/24'

param vnetASEAddressPrefix = '11.0.0.0/16'

param adminPassword = '__adminPassword__'

param adminUsername = '__adminUsername__'

param createLogicApp = true
