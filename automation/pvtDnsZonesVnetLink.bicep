param dnsZoneNames array
param vnetName string
param vnetResourceGroupName string

resource pvtDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' existing = [for item in dnsZoneNames: {
  name: item
}]

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (item, index) in dnsZoneNames: {
  name: '${pvtDnsZones[index].name}-${vnet.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
  parent: pvtDnsZones[index]
}]
