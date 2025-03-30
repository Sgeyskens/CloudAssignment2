@description('The location to deploy all resources')
param location string 

@description('create a container registry')
resource containerRepository 'Microsoft.ContainerRegistry/registries@2024-11-01-preview' = {
  name: 'CRCloudWEuro02'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}
