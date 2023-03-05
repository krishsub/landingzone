param localVnetName string
param remoteVnetSubscriptionId string
param remoteVnetResourceGroupName string
param remoteVnetName string

resource remoteVnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: remoteVnetName
  scope: resourceGroup(remoteVnetSubscriptionId, remoteVnetResourceGroupName)
}

resource localToRemotePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${localVnetName}/${localVnetName}-to-${remoteVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: remoteVnet.id
    }
  }
}
