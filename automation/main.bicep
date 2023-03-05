targetScope = 'subscription'

param location string = 'westeurope'
param hubResourceGroupName string = 'Hub-Resources'
param hubVnetName string = 'Hub-Vnet'
param sharedServicesResourceGroupName string = 'Shared-Resources'
param spokesList array = [
  {
    spokeResourceGroupName: '001-Spoke-Resources'
    spokeVnetName: '001-Spoke-Vnet'
    networkPrefix: '10.1'
  }
  {
    spokeResourceGroupName: '002-Spoke-Resources'
    spokeVnetName: '002-Spoke-Vnet'
    networkPrefix: '10.2'
  }
  {
    spokeResourceGroupName: '003-Spoke-Resources'
    spokeVnetName: '003-Spoke-Vnet'
    networkPrefix: '10.3'
  }
]
param dnsZoneNames array = [
  'krishsub.net'
  'privatelink.azurewebsites.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.documents.azure.com'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.azurecr.io'
  'privatelink.redis.cache.windows.net'
  'privatelink${environment().suffixes.sqlServerHostname}'
  'privatelink.azconfig.io'
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.file.${environment().suffixes.storage}'
  'privatelink.postgres.database.azure.com'
  'privatelink.azurestaticapps.net'
  'privatelink.1.azurestaticapps.net'
  'privatelink.2.azurestaticapps.net'
]

module hubResourceGroup 'resourceGroup.bicep' = {
  name: hubResourceGroupName
  scope: subscription()
  params: {
    location: location
    resourceGroupName: hubResourceGroupName
  }
}

module spokeResourceGroups 'resourceGroup.bicep' = [for spoke in spokesList: {
  name: spoke.spokeResourceGroupName
  scope: subscription()
  params: {
    location: location
    resourceGroupName: spoke.spokeResourceGroupName
  }
}]

module hubVnet 'hub.bicep' = {
  name: 'hubVnet'
  scope: resourceGroup(hubResourceGroup.name)
  params: {
    location: location
    hubVnetName: hubVnetName
    sharedServicesResourceGroupName: sharedServicesResourceGroupName
  }
}

module spokeVnets 'spoke.bicep' = [for spoke in spokesList: {
  name: spoke.spokeVnetName
  scope: resourceGroup(spoke.spokeResourceGroupName)
  params: {
    location: location
    spokeVnetName: spoke.spokeVnetName
    networkPrefix: spoke.networkPrefix
    sharedServicesResourceGroupName: sharedServicesResourceGroupName
  }
  dependsOn: [
    spokeResourceGroups
    hubVnet
  ]
}]

module hubToAllSpokes 'peeringGeneric.bicep' = [for spoke in spokesList: {
  name: 'Hub-To-${spoke.spokeVnetName}'
  scope: resourceGroup(hubResourceGroup.name)
  params: {
    localVnetName: hubVnetName
    remoteVnetName: spoke.spokeVnetName
    remoteVnetResourceGroupName: spoke.spokeResourceGroupName
    remoteVnetSubscriptionId: subscription().subscriptionId
  }
  dependsOn: [
    spokeVnets
    hubVnet
  ]
}]

module allSpokesToHub 'peeringGeneric.bicep' = [for spoke in spokesList: {
  name: '${spoke.spokeVnetName}-To-Hub'
  scope: resourceGroup(spoke.spokeResourceGroupName)
  params: {
    localVnetName: spoke.spokeVnetName
    remoteVnetName: hubVnetName
    remoteVnetResourceGroupName: hubResourceGroupName
    remoteVnetSubscriptionId: subscription().subscriptionId
  }
  dependsOn: [
    spokeVnets
    hubVnet
  ]
}]

module hubPvtDnsZones 'pvtDnsZones.bicep' = {
  name: 'hubPvtDnsZones'
  scope: resourceGroup(hubResourceGroup.name)
  params: {
    dnsZoneNames: dnsZoneNames
  }
}

module spokePvtDnsZonesVnetLink 'pvtDnsZonesVnetLink.bicep' = [for spoke in spokesList: {
  name: '${spoke.spokeVnetName}-PvtDnsZones'
  scope: resourceGroup(hubResourceGroup.name)
  params: {
    dnsZoneNames: dnsZoneNames
    vnetName: spoke.spokeVnetName
    vnetResourceGroupName: spoke.spokeResourceGroupName
  }
  dependsOn: [
    spokeVnets
    hubPvtDnsZones
  ]
}]

module hubPvtDnsZonesVnetLink 'pvtDnsZonesVnetLink.bicep' = {
  name: '${hubVnet.name}-PvtDnsZones'
  scope: resourceGroup(hubResourceGroup.name)
  params: {
    dnsZoneNames: dnsZoneNames
    vnetName: hubVnet.outputs.hubVnetName
    vnetResourceGroupName: hubResourceGroup.name
  }
  dependsOn: [
    hubPvtDnsZones
  ]
}
