
@description('The location to deploy all resources')
param location string = 'westeurope'

targetScope = 'subscription'

@description('create a resource group')
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'RG-Cloud-WEuro-02'
  location: location
}

@description('import the module to create the container repository')
module containerRepository 'containerRepo.bicep' = {
  scope: resourceGroup
  name: 'CRCloudWEuro02'
  params: {location:location}
}


