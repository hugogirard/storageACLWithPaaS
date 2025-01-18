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

@description('Address prefix for the subnet that will contain the management firewall')
param subnetManagementFirewalladdressPrefix string

@description('Address prefix for the subnet that will contain the jumpbox')
param subnetJumpboxaddressPrefix string

var tags = {
  SecurityControl: 'Ignore'
}

var suffix = replace(uniqueString(rgSpoke.id), '-', '')
var privateStorageFileDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var privateStorageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var privateStorageQueueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
var privateStorageTableDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'

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
    subnetManagementFirewalladdressPrefix: subnetManagementFirewalladdressPrefix
  }
}

module storage 'core/storage/storage.bicep' = {
  name: 'storage'
  scope: rgSpoke
  params: {
    location: location
    storageName: 'str${suffix}'
    tags: tags
  }
}

module privateDnsZoneStorage 'core/DNS/storage.dns.zone.bicep' = {
  name: 'dnszonestorage'
  scope: rgHub
  params: {
    privateStorageBlobDnsZoneName: privateStorageBlobDnsZoneName
    privateStorageFileDnsZoneName: privateStorageFileDnsZoneName
    privateStorageQueueDnsZoneName: privateStorageQueueDnsZoneName
    privateStorageTableDnsZoneName: privateStorageTableDnsZoneName
  }
}

module storageVirtualLink 'core/DNS/storage.virtual.link.bicep' = {
  scope: rgHub
  name: 'virtualLinkstorage'
  params: {
    privateStorageBlobDnsZoneName: privateStorageBlobDnsZoneName
    privateStorageFileDnsZoneName: privateStorageFileDnsZoneName
    privateStorageQueueDnsZoneName: privateStorageQueueDnsZoneName
    privateStorageTableDnsZoneName: privateStorageTableDnsZoneName
    vnetName: spokeVnet.outputs.vnetName
    spokeRgName: rgSpoke.name
  }
}

module storagePrivateEndpoint 'core/DNS/storage.record.bicep' = {
  scope: rgSpoke
  name: 'recordstorage'
  params: {
    location: location
    privateStorageBlobDnsZoneId: privateDnsZoneStorage.outputs.privateStorageBlobDnsZoneId
    privateStorageFileDnsZoneId: privateDnsZoneStorage.outputs.privateStorageFileDnsZoneId
    privateStorageQueueDnsZoneId: privateDnsZoneStorage.outputs.privateStorageQueueDnsZoneId
    privateStorageTableDnsZoneId: privateDnsZoneStorage.outputs.privateStorageTableDnsZoneId
    storageId: storage.outputs.storageId
    storageName: storage.outputs.storageName
    subnetId: spokeVnet.outputs.subnetPEId
  }
}

module ase 'core/ase/ase.bicep' = {
  scope: rgSpoke
  name: 'ase'
  params: {
    location: location
    subnetId: spokeVnet.outputs.subnetASEId
    aseName: 'ase-${suffix}'
    vnetId: spokeVnet.outputs.vnetId
  }
}
