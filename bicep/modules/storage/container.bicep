param storageName string
param containerName string

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageName
}

resource symbolicname 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${storage.name}/default/${containerName}'
}
