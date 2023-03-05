param location string = resourceGroup().location
param sharedServicesResourceGroupName string = 'Shared-Resources'
param hubVnetName string = 'Hub-Vnet'

resource hubVnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/22'
      ]
    }
    subnets: [
      {
        name: 'Ingress-Subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: httpHttpsNsg.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Bastion-Subnet'
        properties: {
          addressPrefix: '10.0.1.0/26'
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Apim-Subnet'
        properties: {
          addressPrefix: '10.0.1.128/26'
          networkSecurityGroup: {
            id: apimNsg.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'Compute-Subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource apimNsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'Apim-Nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTPS-Inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
        }
      }
      {
        name: 'Allow-ApiManagement-Inbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'ApiManagement.WestEurope'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3443'
        }
      }
      {
        name: 'Allow-AzureLoadBalancer-Inbound'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '6390'
        }
      }
      {
        name: 'Allow-Storage-Outbound'
        properties: {
          priority: 130
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage.WestEurope'
          destinationPortRange: '443'
        }
      }
      {
        name: 'Allow-Sql-Outbound'
        properties: {
          priority: 140
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Sql.WestEurope'
          destinationPortRange: '1443'
        }
      }
      {
        name: 'Allow-KeyVault-Outbound'
        properties: {
          priority: 150
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault.WestEurope'
          destinationPortRange: '443'
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

output hubVnetName string = hubVnet.name
