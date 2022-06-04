targetScope='subscription'

var name = 'pag-dev-sea'

// module appserviceqithappinsights '../Bicep Templates/Templates/appservice/with_appinsights.bicep' = {
//   name: name 
//   params:{
//     NAME: name
//     LOCATION: 'southeastasia' //for a full list of valid locations, run the command 'az account list-locations -o table'. The valid values are in the 'Name' column.
//     sku: 'S1' 
//     platform: 'windows'
//   }
// }

module appservice '../Bicep Templates/Templates/appservice/with_appinsights_kv_sqlserver_vnet.bicep' = {
  name: name
  params:{
    LOCATION: 'westus'
    NAME: name
    sku: 'P1V2'
    PASSWORD: '7yHL=!zHdBJ+^C)*'
    USERNAME: 'ME'
  }
}
