param NAME string
param location string = resourceGroup().location

output primaryKey string = redisCache.listKeys().primaryKey
resource redisCache 'Microsoft.Cache/Redis@2019-07-01' = {
  name: NAME
  location: location
  properties: {
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0
    }
  }
}
