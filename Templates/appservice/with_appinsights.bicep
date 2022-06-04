/* 
 This template creates the following:

1. App Service
2. Application Insights connected to the app service

*/

targetScope='subscription'

// PARAMETERS
@description('Required. The name of the resource group and the name to be used as a prefix for the resources to be created.')
param NAME string
@description('Required. The location of the resources.')
param LOCATION string
@description('Optional. The SKU of the app service plan resource. Default value is \'S1\'.')
param sku string = 'S1'
@description('Optional. The name of the app service plan resource. Default value is \'<NAME>-asp\'')
param appServicePlanName string = '${NAME}-asp'
@description('Optional. The name of the app service resource. Default value is \'<NAME>-as\'')
param appServiceName string = '${NAME}-as'
@description('Optional. The name of the application insights resource. Default value is \'<NAME>-asp\'')
param applicationInsightsName string = '${NAME}-ai'
@allowed([
  'linux'
  'windows'
])
@description('Optional. Which operating system platform to use for the app service plan and consequently, the app service. Default value is \'windows\'.')
param platform string = 'windows'

@description('Optional. The runtime stack of the app service if running on the Linux platform. Default value is \'DOTNETCORE|6.0\'.')
param linuxFxVersion string = 'DOTNETCORE|6.0'

@description('Optional. The .NET framework version of the app service if runninng on the Windows platform. Default value is \'v6.0\'.')
param netFrameworkVersion string = 'v6.0'

@description('Optional. The tags to be used for the resources to be created.')
param tags object = {}
// VARIABLES
var isUsingLimitedPlan = toLower(sku) == 'f1' || toLower(sku) == 'b1'

// RESOURCE GROUP
resource ResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: NAME
  location: LOCATION 
  tags: tags
}

// MODULES
module AppServicePlan '../../../Bicep Templates/Modules/appserviceplan.bicep' = {
  name: appServicePlanName
  scope: ResourceGroup
  params:{
    NAME: appServicePlanName
    SKU: sku
    location: LOCATION
    platform: platform
    tags: tags
  }

}

module AppService '../../../Bicep Templates/Modules/appservice.bicep' = {
  name: appServiceName
  scope: ResourceGroup
  params:{  
    APPSERVICEPLANID: AppServicePlan.outputs.id
    NAME: appServiceName
    location: LOCATION
    instrumentationkey: ApplicationInsights.outputs.InstrumentationKey
    isUsingLimitedPlan: isUsingLimitedPlan
    linuxFxVersion: linuxFxVersion
    netFrameworkVersion: netFrameworkVersion
    platform: platform
    tags: tags
  }
}

module ApplicationInsights '../../../Bicep Templates/Modules/appinsights.bicep' = {
  name: applicationInsightsName
  scope: ResourceGroup
  params: {
    NAME: applicationInsightsName
    location: LOCATION
    tags: tags
  }
}
