targetScope = 'resourceGroup'

param location string

param subnetId string

param adminUsername string
@secure()
param adminPassword string

param domainName string

param _artifactsLocation string
@secure()
param _artifactsLocationSasToken string


resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'web-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAddress: '10.0.0.20'
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'web'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v3'
    }
    osProfile: {
      computerName: 'web'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'web-osdisk'
        caching: 'ReadOnly'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource createWebserver 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  name: 'createWebserver'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: false
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: uri(_artifactsLocation, 'dsc/webserver/Webserver.ps1.zip${_artifactsLocationSasToken}')
        script: 'Webserver.ps1'
        function: 'Webserver'
      }
      configurationArguments: {
        Computername: 'web'
        Domainname: domainName
      }
    }
    protectedSettings: {
      configurationArguments: {
        Credential: {
          username: '${domainName}\\${adminUsername}'
          password: adminPassword
        }
      }
    }
  }
}
