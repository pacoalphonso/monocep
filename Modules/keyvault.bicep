@description('Required. The name of the keyvault. Must be globally unique and can only contain alphanumeric characters, numbers, and hyphens.')
@minLength(3)
@maxLength(24)
param NAME string

@description('Optional. The location of the resource. Default value is the resource group\'s location')
param location string = resourceGroup().location

@allowed([
  'premium'
  'standard'
])
@description('Optional. The keyvault SKU. Default value is \'standard\'. Set to premium if you need keys to be stored in HSMs (Hardware Security Module).')
param sku string = 'standard'

@description('Optional. The list of object IDs to grant access to the keyvault. Each object must have properties \'objectId\' (the object id of the resource to grant access to), and \'giveFullAccess\' (if set to \'true\', the object will be given full permissions, including purging secrets, otherwise, only read-only permisions will be given).')
param accessObjects array = []

@description('Optional. The tags for additional information about the resource.')
param tags object = {}

@description('Optional. The list of secrets to store in the key vault. Each secret must have properties \'name\' and \'value\'. Additional properties which can be set are \'contentType\' (a description of the secret\'content type), and \'enabled\' (\'true\' to enable the secret, \'false\' to disable it).')
param secrets array = []

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: NAME
  tags: tags
  location: location
  properties: {
    enableSoftDelete: false
    tenantId: subscription().tenantId
    accessPolicies:[ for object in accessObjects: {
      tenantId: subscription().tenantId
      objectId: object.objectId
      permissions: object.giveFullAccess ?  {
        keys: [
          'all'
        ]
        secrets: [
          'all'
        ]
        certificates:[
          'all'
        ]
      }:{
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
      ]
      certificates:[
        'get'
        'list'
      ]
    }
    }]
    sku: {
      name: sku
      family: 'A'
    }
  }
}

resource keyvaultsecrets 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = [for secret in secrets : {
  parent: keyvault
  name: '${secret.name}'
  tags: tags
  properties: {
    value: '${secret.value}'
    contentType: '${secret.contentType}'
    attributes:{
      enabled: secret.enabled
    }
  }
}]

/*
resource keyvaultkeys 'Microsoft.KeyVault/vaults/keys@2019-09-01' = [for key in keys : {
  name: '${NAME}/${key.Name}'
  properties:{

  }
}]

resource keyvaultcertificates 'Microsoft.Web/certificates@2021-02-01' = [for certificate in certificates : {
  name: '${certificate.Name}'
  location: resourceGroup().location
  properties: {
    keyVaultId: keyvault.id
    keyVaultSecretName: certificate.KeyVaultSecretName
    password: certificate.Password
    serverFarmId: certificate.ServerFarmId
  }  
}]
*/
