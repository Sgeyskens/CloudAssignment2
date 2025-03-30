@description('The location to deploy all resources')
param location string = resourceGroup().location

param port int = 80
targetScope = 'resourceGroup'

@description('Reference to an existing Azure Container Registry')
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: 'CRCloudWEuro02'
}

@description('Create a network security group (NSG) to control inbound/outbound traffic')
resource networkSecurity 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'NSPublic'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allowHttp'
        properties: {
          description: 'Allow inbound HTTP traffic to the container.'
          sourceAddressPrefix: '*' // Allow traffic from any source
          sourcePortRange: '80'
          destinationAddressPrefix: '*' // Allow traffic to any destination
          destinationPortRange: '80'
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          priority: 100 // Lower number means higher priority
        }
      }
    ]
  }
}

@description('Create a route table to route traffic to the internet')
resource routingTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'publicRoutingTable'
  location: location
  properties: {
    routes: [
      {
        name: 'publicRoute'
        properties: {
          addressPrefix: '0.0.0.0/24' // Destination address range
          nextHopType: 'Internet' // Route traffic to the internet
        }
      }
    ]
  }
}

@description('Create a virtual network')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'VNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16' // IP range for the virtual network
      ]
    }
  }
}

@description('Create a subnet within the virtual network and associate NSG and route table')
resource virtualNetworkSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: virtualNetwork
  name: 'Subnet1'
  properties: {
    addressPrefix: '10.0.4.0/24' // Subnet IP range
    networkSecurityGroup: { id: networkSecurity.id } // Attach the NSG
    delegations: [
      {
        name: 'DelegationService'
        properties: {
          serviceName: 'Microsoft.ContainerInstance/containerGroups' // Delegate for ACI
        }
      }
    ]
    routeTable: {
      id: routingTable.id // Attach the route table
    }
  }
}

@description('Create a network profile to assign to the container')
resource networkProfile 'Microsoft.Network/networkProfiles@2020-11-01' = {
  name: 'networkProfile'
  location: location
  properties: {
    containerNetworkInterfaceConfigurations: [
      {
        name: 'eth0'
        properties: {
          ipConfigurations: [
            {
              name: 'ipConfigurationProfile'
              properties: {
                subnet: {
                  id: virtualNetworkSubnet.id
                }
              }
            }
          ]
        }
      }
    ]
  }
}

@description('Deploy a container group with a publicly accessible IP address')
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: 'containerGroup'
  location: location
  properties: {
    containers: [
      {
        name: 'flaskcrudapp'
        properties: {
          image: 'crcloudweuro02.azurecr.io/flaskcrudapp:latest' // Image from ACR
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }
    ]
    osType: 'Linux'
    
    // Assign a public IP address for direct access
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }

    imageRegistryCredentials: [
      {
        server: acr.properties.loginServer
        username: listCredentials(acr.id, '2023-01-01-preview').username
        password: listCredentials(acr.id, '2023-01-01-preview').passwords[0].value
      }
    ]
    
    restartPolicy: 'Always' // Container will always restart if it stops
  }
}
