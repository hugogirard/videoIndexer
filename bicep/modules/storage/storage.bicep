param location string
param name string
param tags object

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'    
  }
  tags: tags
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}

output storageName string = storage.name
output storageId string = storage.id

