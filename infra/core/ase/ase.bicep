param aseName string
param location string
param subnetId string

resource asev3 'Microsoft.Web/hostingEnvironments@2024-04-01' = {
  name: aseName
  location: location
  kind: 'ASEV3'
  properties: {
    internalLoadBalancingMode: 'Web, Publishing'
    virtualNetwork: {
      id: subnetId
    }
  }
}
