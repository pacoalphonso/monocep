targetScope='subscription'

var name = 'pag-dev-sea2'
param location string = 'westus'

// module appserviceqithappinsights '../Bicep Templates/Templates/appservice/with_appinsights.bicep' = {
//   name: name 
//   params:{
//     NAME: name
//     LOCATION: 'southeastasia' //for a full list of valid locations, run the command 'az account list-locations -o table'. The valid values are in the 'Name' column.
//     sku: 'S1' 
//     platform: 'windows'
//   }
// }

// module appservice 'Templates/appservice/with_appinsights_kv_sqlserver_vnet.bicep' = {
//   name: name
//   params:{
//     LOCATION: location
//     NAME: name
//     sku: 'P1V2'
//     PASSWORD: '7yHL=!zHdBJ+^C)*'
//     USERNAME: 'ME'
//   }
// }

module functionApp 'Templates./appservice/with_appinsights_kv_redis_sqlserver_vnet.bicep' = {
  name: name
  params:{
    LOCATION: location
    NAME: name
    sku: 'P1V2'
    PASSWORD: '7yHL=!zHdBJ+^C)*'
    USERNAME: 'ME'
  }
}
