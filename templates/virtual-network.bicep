targetScope = 'resourceGroup'

param location string
param nsgId string

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
            id: nsgId
          }
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
