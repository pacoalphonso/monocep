@description('Required. The name of the app service plan.')
param NAME string
@description('Requires. The SKU to use for the app service plan.')
param SKU string
@description('Optional. The number of instances to deploy. Default value is 1')
param capacity int = 1
@description('Optional. The location of the resource. Default value is the resource group\'s location')
param location string = resourceGroup().location
@description('Optional. The tags for additional information about the resource.')
param tags object = {}

@allowed([
  'linux'
  'windows'
])
@description('Optional. Which operating system platform to use for the app service plan and consequently, the app service. Default value is \'windows\'.')
param platform string = 'windows'

@description('Output. The object.')
output appServicePlan object = AppServicePlan

output id string = AppServicePlan.id
resource AppServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: NAME
  location: location
  properties:{
    reserved: toLower(platform) == 'linux' ? true : false
  }
  sku: {
    name: SKU
    capacity: capacity
  }
  tags: tags
}
