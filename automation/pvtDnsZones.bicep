param dnsZoneNames array

resource pvtDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = [for item in dnsZoneNames: {
  name: item
  location: 'global'
}]
