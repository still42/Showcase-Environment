targetScope = 'resourceGroup'

param location string

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

output nsgId string = nsg.id
