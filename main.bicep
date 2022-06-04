param location string
param environment string

var sharedParams = json(loadTextContent('./shared.json'))
var prefix = '${sharedParams.projectName}-${environment}-${sharedParams.resourceGroupLocationShort}a'
targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: prefix
  location: location 
}
module appserviceplan '../Bicep Templates/Modules/appserviceplan.bicep' = {
  name: '${prefix}-asp'
  scope:rg
  params:{
    NAME: '${prefix}-asp'
    SKU: 'S1'  
    tags:{
      project: sharedParams.projectName
    }
  }
}


module keyvault '../Bicep Templates/Modules/keyvault.bicep' = {
  name: '${prefix}-kv'
  scope:rg
  params:{
    NAME: '${prefix}-kv'
    secrets: [
      {
        Name: '${sqlserver.name}--connectionstring'
        Value: sqlserver.outputs.connectionstring
      }
    ]
    objects: [
       {
          objectId: 'f35fb681-3bd4-427b-b3de-30d95b2c5a1b'
          giveFullAccess: true
       }
       {
          objectId: appservice.outputs.objectId
          giveFullAccess: false
       }
     ]
    tags:{
      project: sharedParams.projectName
    }  
  }
}

module appservice '../Bicep Templates/Modules/appservice.bicep' = {
  name: '${prefix}-as'
  scope: rg
  params:{
    APPSERVICEPLANID: appserviceplan.outputs.id
    NAME: '${prefix}-as'
    subnetid: vnet.outputs.vnet.properties.subnets[0].id
    tags: {
      AppServicePlan: appserviceplan.name
    }
  }
}
/*
module redis '../Bicep Templates/Templates/redis.bicep' = {
  name: '${prefix}-redis'
  params: {
    NAME:'${prefix}-redis'
  }
  scope: rg
}
*/

// module siteextensions '../Bicep Templates/Templates/siteextensions.bicep' = {
//   name: '${prefix}-asse'
//   params: {
//     APPSERVICENAME: '${prefix}-as'
//   }
//   dependsOn:[
//     appservice
//     sqlserver
//   ]
//   scope: rg
// }

module sqlserver '../Bicep Templates/Modules/sqlserver.bicep' = {
  name: '${prefix}-sqlserver'
  scope: rg
  params: {
    NAME: '${prefix}-sqlserver'
    ADMINUSER: 'ME'
    PASSWORD: '7yHL=!zHdBJ+^C)*'
  }
}

module vnet '../Bicep Templates/Modules/vnet.bicep' = {
  name: '${prefix}-vnet'
  scope: rg
  params:{
    NAME:'${prefix}-vnet'
    addressprefixes:[
      '10.0.0.0/16'
    ]
    
    subnets:[
      {
        name: '${prefix}-vnet-sn-delegation'
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
    ]
  }
}

