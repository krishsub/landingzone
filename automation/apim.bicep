param location string = resourceGroup().location
param apimName string
param publisherEmail string = 'krishsub@microsoft.com'
param publisherName string = 'Microsoft Internal'
param hubVnetName string = 'Hub-Vnet'
param apimSubnetName string = 'Apim-Subnet'
param customDnsSuffix string = 'krishsub.net'
param keyVaultName string = 'kv-krishsub'

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${hubVnetName}/${apimSubnetName}'
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' existing = {
  name: '${keyVaultName}/krishsubNetWildcard'
  scope: resourceGroup('Shared-Resources')
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'test-mi-666'
  scope: resourceGroup('000-Scrap-Resources')
}

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimName
  location: location
  sku: {
    name: 'Premium'
    capacity: 1
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnet.id
    }
    virtualNetworkType: 'Internal'
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: 'api666.${customDnsSuffix}'
        keyVaultId: keyVaultSecret.properties.secretUri
        certificateSource: 'KeyVault'
        identityClientId: userAssignedIdentity.properties.clientId
        defaultSslBinding: true
      }
    ]
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
}
