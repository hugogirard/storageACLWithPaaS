param location string
param addressPrefixe string
param subnetFirewalladdressPrefix string
param subnetManagementFirewalladdressPrefix string
param subnetJumpboxaddressPrefix string

resource nsgJumpbox 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-jumpbox'
  location: location
  properties: {
    securityRules: []
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-hub'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixe
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: subnetFirewalladdressPrefix
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: subnetManagementFirewalladdressPrefix
        }
      }
      {
        name: 'snet-jumpbox'
        properties: {
          addressPrefix: subnetJumpboxaddressPrefix
          networkSecurityGroup: {
            id: nsgJumpbox.id
          }
        }
      }
    ]
  }
}
