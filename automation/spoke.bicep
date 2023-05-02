param location string = resourceGroup().location
param spokeVnetName string = '001-Spoke-Vnet'
param sharedServicesResourceGroupName string = 'Shared-Resources'
param networkPrefix string = '10.1'

resource spokeVnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${networkPrefix}.0.0/23'
      ]
    }
    subnets: [
      {
        name: 'Ingress-Subnet'
        properties: {
          addressPrefix: '${networkPrefix}.0.0/26' // 64 addresses (- 5 reserved)
          networkSecurityGroup: {
            id: httpHttpsNsg.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Compute1-Subnet'
        properties: {
          addressPrefix: '${networkPrefix}.0.64/26' // 64 addresses (- 5 reserved)
          networkSecurityGroup: {
            id: defaultNsg.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Compute2-Subnet'
        properties: {
          addressPrefix: '${networkPrefix}.0.128/26' // 64 addresses (- 5 reserved)
          networkSecurityGroup: {
            id: defaultNsg.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'PvtEndpoints-Subnet'
        properties: {
          addressPrefix: '${networkPrefix}.0.192/26' // 64 addresses (- 5 reserved)
          networkSecurityGroup: {
            id: defaultNsg.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource httpHttpsNsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' existing = {
  name: 'Http-Https-Nsg'
  scope: resourceGroup(sharedServicesResourceGroupName)
}

resource defaultNsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' existing = {
  name: 'Default-Nsg'
  scope: resourceGroup(sharedServicesResourceGroupName)
}
