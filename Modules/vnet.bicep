param NAME string
param location string = resourceGroup().location
param subnets array = []
param addressprefixes array = []

output vnet object = virtualNetwork
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: NAME
  location: location
  properties: { 
    
    addressSpace: {
      addressPrefixes: addressprefixes
    }
    subnets: subnets    
    }
}
 