param privateEndpointIP string
param dnsName string

resource dns 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: dnsName
}

resource aRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: dns
  name: '@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateEndpointIP
      }
    ]
  }
}
