targetScope = 'subscription'

@minLength(4)
@maxLength(20)
@description('Resource group name for the spoke')
param spokeResourceGroupName string

@minLength(4)
@maxLength(20)
@description('Resource group name for the hub')
param hubResourceGroupName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Address prefix for the virtual network that will contain the ASE v3')
param vnetASEAddressPrefix string

@description('Address prefix for the subnet that will contain the ASE v3')
param subnetASEAddressPrefix string

@description('Address prefix for the subnet that will contain the private endpoint')
param subnetPEAddressPrefix string

@description('Address prefix for the virtual network that will contain the hub')
param hubVnetAddressPrefix string

@description('Address prefix for the subnet that will contain the firewall')
param subnetFirewalladdressPrefix string

@description('Address prefix for the subnet that will contain the jumpbox')
param subnetJumpboxaddressPrefix string

// var tags = {
//   'SecurityControl': 'Ignore'
// }

var suffix = replace((rgSpoke.id), '-', '')

resource rgSpoke 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: spokeResourceGroupName
  location: location
}

resource rgHub 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: hubResourceGroupName
  location: location
}

module spokeVnet 'core/network/spoke.bicep' = {
  scope: rgSpoke
  name: 'spokeVnet'
  params: {
    location: location
    subnetASEAddressPrefix: subnetASEAddressPrefix
    subnetPEAddressPrefix: subnetPEAddressPrefix
    vnetAddressPrefix: vnetASEAddressPrefix
  }
}

module hubVnet 'core/network/hub.bicep' = {
  name: 'hubVnet'
  scope: rgHub
  params: {
    location: location
    addressPrefixe: hubVnetAddressPrefix
    subnetFirewalladdressPrefix: subnetFirewalladdressPrefix
    subnetJumpboxaddressPrefix: subnetJumpboxaddressPrefix
  }
}

module storage 'storage/storage.bicep' = {
  name: 'storage'
  scope: rgSpoke
  params: {
    location: location
    storageName: 'str${suffix}'
  }
}

// module ase 'core/ase/ase.bicep' = {
//   scope: rg
//   name: 'ase'
//   params: {
//     location: location
//     subnetId: vnet.outputs.subnetId
//     aseName: 'ase-${suffix}'
//   }
// }
