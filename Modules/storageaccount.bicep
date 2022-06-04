@description('Required. The name of the app service plan.')
param NAME string

@description('Optional. The location of the resource. Default value is the resource group\'s location')
param location string = resourceGroup().location

@description('Optional. The kind of storage type. Default value is \'BlobStorage\'.')
param storageKind string = 'BlobStorage'

@description('Optional. The SKU of the storage account. Default value is \'Standard_LRS\'.')
param sku string = 'Standard_LRS'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: NAME
  location: location

  kind: storageKind
  properties:{
    
  }
  sku: {
    name: sku
  }
}
