@description('Required. The name of the app service plan.')
param NAME string

@description('Optional. The location of the resource. Default value is the resource group\'s location')
param location string = resourceGroup().location

@description('Optional. The tags for additional information about the resource.')
param tags object = {}

@description('Output. The instrumentation key.')
output InstrumentationKey string = AppInsights.properties.InstrumentationKey

@description('Output. The application insights object.')
output appInsights object = AppInsights

resource AppInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: NAME
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
  tags: tags
}
