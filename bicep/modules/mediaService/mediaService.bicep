param location string
param suffix string
param userAssignedIdentityId object
param storageId string

resource media 'Microsoft.Media/mediaservices@2021-11-01' = {
  name: 'mediasrv${suffix}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: userAssignedIdentityId
  }
  properties: {
    storageAccounts: [
      {
        id: storageId
        type: 'Primary'
      }
    ] 
  }
}

output mediaServiceId string = media.id
output mediaServiceName string = media.name
