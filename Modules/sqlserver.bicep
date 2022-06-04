@description('Required. The name of the sql server.')
param NAME string

@description('Required. The administrator name to create.')
param ADMINUSER string

@description('Required. The administrator password to create.')
@secure()
param PASSWORD string

@description('Optional. The name of the sql server database. Default value is \'<NAME>-db\'')
param sqlserverdatabasename string = '${NAME}-db'

@description('Optional. The location of the resource.')
param location string = resourceGroup().location

@description('Optional. The tags to be used for the resources to be created.')
param tags object = {}

@description('Output.The database\'s fully qualified domain name. Primarily used for constructing the connection string to the database.')
output fqdn string = SqlServer.properties.fullyQualifiedDomainName

@description('Optional. The SKU of the database. Availability for some SKUs are based on region. Default value is \'Basic\'. Be careful with this setting to avoid bill shock!')
@allowed([
  'Basic'
  'Business'
  'BusinessCritical'
  'DataWarehouse'
  'Free'
  'GeneralPurpose'
  'Hyperscale'
  'Premium'
  'PremiumRS'
  'Standard'
  'Stretch'
  'System'
  'System2'
  'Web'
])
param edition string = 'Basic'

@description('Optional. The max size in bytes of the database. Default value is \'1073741824\', which is 1 gibibyte.')
param maxDbSizeInBytes string = '1073741824'

@description('Output. The SqlServer object.')
output sqlServer object = SqlServer

@description('Output. The SqlServer database object.')
output sqlServerDatabase object = SqlServerDatabase
resource SqlServer 'Microsoft.Sql/servers@2014-04-01' = {
  name: NAME
  location: location
  tags: tags
  properties:{
    administratorLogin: ADMINUSER
    administratorLoginPassword: PASSWORD
  }
}

resource SqlServerDatabase 'Microsoft.Sql/servers/databases@2014-04-01' = {
  parent: SqlServer
  name: sqlserverdatabasename
  location: location
  tags: tags
  properties: {
    edition: edition
    maxSizeBytes: maxDbSizeInBytes
    requestedServiceObjectiveName: 'Basic'
  }
}
