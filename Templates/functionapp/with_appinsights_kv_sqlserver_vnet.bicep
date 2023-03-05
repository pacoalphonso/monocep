/* 
This template creates the following:

1. Function App with Vnet integration
2. Application Insights connected to the function app
3. Sql Server (for hosting the Sql Database)
4. Sql Database (as the backed data store for the function app)
5. Azure Keyvault for storing the connection string and giving read-only access to the function app
6. Virtual network
*/

targetScope='subscription'

// REQUIRED PARAMETERS
@description('Required. The name of the resource group and the name to be used as a prefix for the resources to be created.')
param NAME string

@description('Required. The location of the resources.')
param LOCATION string

@description('Required. The name of the user login to create.')
param USERNAME string

@description('Required. The user password to create.')
@secure()
param PASSWORD string

// OPTIONAL PARAMETERS
@description('Optional. The SKU of the app service plan resource. Default value is \'S1\'.')
param sku string = 'S1'

@description('Optional. The name of the app service plan resource. Default value is \'<NAME>-asp\'')
param appServicePlanName string = '${NAME}-asp'

@description('Optional. The name of the function app resource. Default value is \'<NAME>-fa\'')
param functionAppName string = '${NAME}-fa'

@description('Optional. The name of the application insights resource. Default value is \'<NAME>-ai\'')
param applicationInsightsName string = '${NAME}-ai'

@description('Optional. The name of the sql server resource. Default value is \'<NAME>-sqlserver\'')
param sqlServerName string = '${NAME}-sqlserver'

@description('Optional. The name of the keyvault resource. Default value is \'<NAME>-kv\'')
param keyVaultName string = '${NAME}-kv'

// @description('Optional. The list of object IDs to grant access to the keyvault. Each object must have properties \'objectId\' (the object id of the resource to grant access to), and \'giveFullAccess\' (if set to \'true\', the object will be given full permissions, including purging secrets, otherwise, only read-only permisions will be given).')
// param accessObjects array = []

@description('Optional. The name of the sql server database resource. Default value is \'<NAME>-sqldb\'')
param sqlServerDatabaseName string = '${NAME}-db'

@allowed([
  'linux'
  'windows'
])
@description('Optional. Which operating system platform to use for the app service plan and consequently, the function app. Default value is \'windows\'.')
param platform string = 'windows'

@description('Optional. The runtime stack of the function app if running on the Linux platform. Default value is \'DOTNETCORE|6.0\'.')
param linuxFxVersion string = 'DOTNETCORE|6.0'

@description('Optional. The .NET framework version of the function app if runninng on the Windows platform. Default value is \'v6.0\'.')
param netFrameworkVersion string = 'v6.0'

@description('Optional. The tags to be used for the resources to be created.')
param tags object = {}

@description('Optional. If false, the RouteAll feature of the Vnet will be disabled. Default value is false.')
param enableVnetRouteAll bool = false

// VARIABLES
var isUsingLimitedPlan = toLower(sku) == 'f1' || toLower(sku) == 'b1'

@description('The connection string used to connect to the database.')
var sqlServerConnectionString = 'Server=tcp:${SqlServer.outputs.fqdn},1433;Initial Catalog=${sqlServerDatabaseName}; Persist Security Info=false; User Id=${USERNAME}; Password=${PASSWORD};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

// RESOURCE GROUP
resource ResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: NAME
  location: LOCATION 
  tags: tags
}

// MODULES
module AppServicePlan '../../Modules/appserviceplan.bicep' = {
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

module FunctionApp '../..//Modules/functionapp.bicep' = {
  name: functionAppName
  scope: ResourceGroup
  params:{  
    APPSERVICEPLANID: AppServicePlan.outputs.id
    location: LOCATION
    NAME: functionAppName
    instrumentationkey: ApplicationInsights.outputs.InstrumentationKey
    isUsingLimitedPlan: isUsingLimitedPlan
    linuxFxVersion: linuxFxVersion
    netFrameworkVersion: netFrameworkVersion
    platform: platform
    enableVnetRouteAll: enableVnetRouteAll
    subnetid: Vnet.outputs.vnet.properties.subnets[0].id
    connectionStrings:[
      {
        connectionString: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${functionAppName}-connection)'
        name: '${functionAppName}-connection'
        type: 'Custom'
      }
    ]
    tags: tags
  }
}

module ApplicationInsights '../../Modules/appinsights.bicep' = {
  name: applicationInsightsName
  scope: ResourceGroup
  params: {
    NAME: applicationInsightsName
    location: LOCATION
    tags: tags
  }
}

module SqlServer '../../Modules/sqlserver.bicep' = {
  name: sqlServerName
  scope: ResourceGroup
  params: {
    ADMINUSER: USERNAME
    NAME: sqlServerName
    PASSWORD: PASSWORD
    location:LOCATION
    sqlserverdatabasename: sqlServerDatabaseName
    tags: tags
  }
}

module KeyVault '../../Modules/keyvault.bicep' = {
  name: keyVaultName
  scope: ResourceGroup
  params: {
    NAME: keyVaultName
    location: LOCATION
    accessObjects: [
      {
        objectId: FunctionApp.outputs.objectId
        giveFullAccess: false
      }
      {
        objectId: 'f35fb681-3bd4-427b-b3de-30d95b2c5a1b'
        giveFullAccess: true
      }
    ]
    secrets: [
      {
        name: '${functionAppName}-connection'
        value: sqlServerConnectionString
        enabled: true
        contentType: 'ConnectionString'
      }
    ]
  }
}

module Vnet '../../Modules/vnet.bicep' = {
  name: '${functionAppName}-vnet'
  params: {
    NAME: '${functionAppName}-vnet'
    location: LOCATION
    addressprefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        name: '${functionAppName}-vnet-sn'
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: [
            {
              name: '${functionAppName}-vnet-sn-delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }

      // {
      //   name: '${sqlServerName}-vnet-sn'
      //   properties: {
      //     addressPrefix: '10.0.1.0/24'
      //     delegations: [
      //       {
      //         name: '${appServiceName}-vnet-sn-delegation'
      //         properties: {
      //           serviceName: 'Microsoft.Sql/managedInstances'
      //         }
      //       }
      //     ]
      //   }
      // }
    ]
  }
  scope: ResourceGroup
}
