param location string
param suffix string
param managedIdentityResourceId string
param mediaServiceAccountResourceId string

var accountName = 'vidx-${suffix}'

resource avamAccount 'Microsoft.VideoIndexer/accounts@2022-08-01' = {
  name: accountName
  location: location
  identity:{
    type: 'UserAssigned'
    userAssignedIdentities : {
      '${managedIdentityResourceId}' : {}
    }
  }
  properties: {
    mediaServices: {
      resourceId: mediaServiceAccountResourceId
      userAssignedIdentity: managedIdentityResourceId
    }
  }
}

output videoIndexerName string = avamAccount.name
output videoIndexerGetTokenEndpoint string = 'https://management.azure.com/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroup().name}/providers/Microsoft.VideoIndexer/accounts/${avamAccount.name}/generateAccessToken?api-version=2022-04-13-preview'
output videoIndexerUploadVideoEndpoint string = 'https://api.videoindexer.ai/${location}/Accounts/${avamAccount.properties.accountId}/Videos'
output videoIndexerAccountId string = avamAccount.properties.accountId
