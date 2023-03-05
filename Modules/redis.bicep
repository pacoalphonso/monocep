param NAME string
param location string = resourceGroup().location

output connectionString string = '${resourceGroup().name}-redis.redis.cache.windows.net:6380,password=${redisCache.listKeys().primaryKey},ssl=True,abortConnect=False'

resource redisCache 'Microsoft.Cache/redis@2022-05-01' = {
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
