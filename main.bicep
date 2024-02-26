targetScope = 'resourceGroup'

param location string

param domainName string = 'ntwrk.com'

param adminUsername string = 'domainadmin'

@secure()
param adminPassword string

param _artifactsLocation string = deployment().properties.templateLink.uri

@secure()
param _artifactsLocationSasToken string = ''

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'vnet-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'default'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          protocol: 'Tcp'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

module dc 'templates/domaincontroller.bicep' = {
  name: 'dc'
  params: {
    _artifactsLocation: _artifactsLocation 
    _artifactsLocationSasToken: _artifactsLocationSasToken
    adminPassword: adminPassword
    adminUsername: adminUsername
    domainName: domainName
    location: location
    subnetId: vnet.properties.subnets[0].id
  }
}

resource vnetUpdate 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnetUpdate'
  location: location
  dependsOn: [
    dc
  ]
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
    dhcpOptions: {
      dnsServers: [
        '10.0.0.10'
      ]
    }
  }
}

module web 'templates/webserver.bicep' = {
  name: 'web'
  params: {
    _artifactsLocation: _artifactsLocation 
    _artifactsLocationSasToken: _artifactsLocationSasToken
    adminPassword: adminPassword
    adminUsername: adminUsername
    domainName: domainName
    location: location
    subnetId: vnetUpdate.properties.subnets[0].id
  }
}
