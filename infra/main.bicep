targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Address prefix for the virtual network that will contain the ASE v3')
param vnetAddressPrefix string

@description('Address prefix for the subnet that will contain the ASE v3')
param subnetAddressPrefix string

var tags = {
  'SecurityControl': 'Ignore'
}

var suffix = uniqueString(rg.id)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-logicapp-storage'
  location: location
  tags: tags
}

module vnet 'core/network/spoke.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    location: location
    subnetAddressPrefix: subnetAddressPrefix
    vnetAddressPrefix: vnetAddressPrefix
  }
}

module ase 'core/ase/ase.bicep' = {
  scope: rg
  name: 'ase'
  params: {
    location: location
    subnetId: vnet.outputs.subnetId
    aseName: 'ase-${suffix}'
  }
}
