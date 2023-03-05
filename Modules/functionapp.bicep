// REQUIRED PARAMETERS
@description('Required. The name of the function app.')
param NAME string

@description('Required. The app service plan\'s id.')
param APPSERVICEPLANID string

// optional parameters
@description('Optional. The location of the resource. Default value is the resource group\'s location')
param location string = resourceGroup().location

@description('Optional. The tags for additional information about the resource.')
param tags object = {}

@description('Optional. The subnet id for the function app to use.')
param subnetid string = ''

@description('Optional. The .NET framework version of the function app. Default value is \'v6.0\'.')
param netFrameworkVersion string = 'v6.0'

@description('Optional. The runtime stack of the function app. Default value is \'DOTNETCORE|6.0\'.')
param linuxFxVersion string = 'DOTNETCORE|6.0'

@description('Optional. The ingestion endpoint for application insights. Default value is \'https://<resource group location>-1.in.applicationinsights.azure.com/\'.')
param ingestionEndpoint string = 'https://${location}-1.in.applicationinsights.azure.com/'

@description('Optional. The minimum TLS version the function appservice will use. Default value is \'1.2\'.')
param minTlsVersion string = '1.2'

@description('Optional. The application insight\'s instrumentation key. There is no default value.')
param instrumentationkey string = ''

@description('Optional. If true, the app service plan is using a limited plan and thus cannot make use of certain paid plan features: \'Always On\', client certs, and 64-bit process. Default value is false.')
param isUsingLimitedPlan bool = false

@description('Optional. Which operating system platform to use for the app service plan and consequently, the function app. Default value is \'windows\'.')
param platform string = 'windows'

@description('Optional. The list of connection string to save in the function app. Each connection string must have properties \'connectionString\' (The actual connection string value, which can also hold a referece to Azure Keyvault), and \'name\' (The name of the connection string). An optional property, \'type\', is used to describe the type of the connection string.')
param connectionStrings array = []

@description('Optional. If true, the Vnet routeAll feature will be turned on. Default value is false.')
param enableVnetRouteAll bool = false

// OUTPUT
@description('Output. The function app\'s object id.')
output objectId string = FunctionApp.identity.principalId

@description('Output. The function app object.')
output appService object = FunctionApp


// RESOURCE
resource FunctionApp 'Microsoft.Web/sites@2021-02-01' = {
  
  name: NAME
  location: location
  identity:{
    type:'SystemAssigned'
  }
  tags: tags
  kind: 'functionapp'
  properties: {
    serverFarmId: APPSERVICEPLANID
    httpsOnly: true
    virtualNetworkSubnetId: subnetid == '' ? null : subnetid
    clientCertEnabled: isUsingLimitedPlan ? false : true
    clientCertMode: isUsingLimitedPlan ? 'Optional' : 'OptionalInteractiveUser'
    siteConfig:{
      
      appSettings: instrumentationkey != '' ? [
        {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: instrumentationkey
        }
        {
        name : 'APPLICATION_INSIGHTS_CONNECTION_STRING'
        value: 'InstrumentationKey=${instrumentationkey};IngestionEndpoint=${ingestionEndpoint}'
        }
        {
          name : 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: platform == 'windows' ? null : 'InstrumentationKey=${instrumentationkey};IngestionEndpoint=${ingestionEndpoint}'
        }
          {
          name : 'APPINSIGHTS_PROFILERFEATURE_VERSION'
          value: '1.0.0'
        }
        {
          name : 'APPINSIGHTS_SNAPSHOTFEATURE_VERSION'
          value: '1.0.0'
        }
        {
          name : 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: platform == 'windows' ? '~2' : '~3'
        }
        {
          name : 'DiagnosticServices_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name : 'InstrumentationEngine_EXTENSION_VERSION'
          value : '~1'
        }
        {
          name : 'SnapshotDebugger_EXTENSION_VERSION'
          value: '~1'
        }
        {
          name : 'XDT_MicrosoftApplicationInsights_BaseExtensions'
          value: '~1'
        }
        {
          name : 'XDT_MicrosoftApplicationInsights_Java'
          value: '1'
        }
        {
          name : 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'Recommended'
        }
        {
          name : 'XDT_MicrosoftApplicationInsights_NodeJS'
          value: '1'
        }
        {
          name : 'XDT_MicrosoftApplicationInsights_PreemptSdk'
          value:  platform == 'windows' ? 'disabled' : 'enabled'
        }
  
      ] : []
      connectionStrings:connectionStrings
      metadata:[
        {
          name: 'CURRENT_STACK'
          value: 'dotnetcore'
        }
      ]
      netFrameworkVersion: netFrameworkVersion
      linuxFxVersion: platform == 'linux' ? linuxFxVersion : null
      alwaysOn: isUsingLimitedPlan ? false : true
      http20Enabled: true
      minTlsVersion: minTlsVersion
      use32BitWorkerProcess: isUsingLimitedPlan ? true : false
      vnetRouteAllEnabled: enableVnetRouteAll
    }    
  }
}
