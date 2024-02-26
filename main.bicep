targetScope = 'resourceGroup'

param location string = 'westeurope'

param domainName string = 'ntwrk.com'

param adminUsername string = 'domainadmin'

@secure()
param adminPassword string

param _artifactsLocation string = deployment().properties.templateLink.uri

@secure()
param _artifactsLocationSasToken string = ''

module nsg 'templates/network-security-group.bicep' = {
  name: 'nsg'
  params: {
    location: location 
  }
}

module vnet 'templates/virtual-network.bicep' = {
  name: 'vnet'
  dependsOn: [
    nsg
  ]
  params: {
    location: location
    nsgId: nsg.outputs.nsgId
  }
}

module dc 'templates/domaincontroller.bicep' = {
  name: 'dc'
  dependsOn: [
    vnet
  ]
  params: {
    _artifactsLocation: _artifactsLocation 
    _artifactsLocationSasToken: _artifactsLocationSasToken
    adminPassword: adminPassword
    adminUsername: adminUsername
    domainName: domainName
    location: location
    subnetId: vnet.outputs.subnetId
  }
}

module vnetUpdate 'templates/virtual-network-update.bicep' = {
  name: 'vnetUpdate'
  dependsOn: [
    dc, nsg, vnet
  ]
  params: {
    location: location
    nsgId: nsg.outputs.nsgId
  }
}

module web 'templates/webserver.bicep' = {
  name: 'web'
  dependsOn: [
    dc, nsg, vnet, vnetUpdate
  ]
  params: {
    _artifactsLocation: _artifactsLocation 
    _artifactsLocationSasToken: _artifactsLocationSasToken
    adminPassword: adminPassword
    adminUsername: adminUsername
    domainName: domainName
    location: location
    subnetId: vnetUpdate.outputs.subnetId
  }
}
