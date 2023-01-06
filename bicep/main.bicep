targetScope='subscription'

param location string
param resourceGroupName string
@secure()
param displayName string

var suffix = uniqueString(rg.id)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module identity 'modules/identity/userassigned.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'identity'
  params: {
    location: location
    suffix: suffix
  }
}

module storageVideo 'modules/storage/storage.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'storageVideo'
  params: {
    name: 'strm${suffix}'
    location: location    
    tags: {
      description: 'Media Service Storage'
    }
  }
}


module storageDocument 'modules/storage/storage.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'storageDocument'
  params: {
    name: 'strd${suffix}'
    location: location 
    tags: {
      description: 'Uploaded audio files'
    }
  }
}

module containerDocument 'modules/storage/container.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'containerDocument'
  params: {
    containerName: 'transcript'
    storageName: storageDocument.outputs.storageName
  }
}

module storageLogicApp 'modules/storage/storage.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'storageLogicApp'
  params: {
    name: 'strla${suffix}'
    location: location    
    tags: {
      description: 'Logic App Storage'
    }
  }
}

module containerAudio 'modules/storage/container.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'containerAudio'
  params: {
    containerName: 'audio'
    storageName: storageLogicApp.outputs.storageName
  }
}

module mediaService 'modules/mediaService/mediaService.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'mediaService'
  params: {
    location: location
    storageId: storageVideo.outputs.storageId
    suffix: suffix
    userAssignedIdentityId: {
      '${identity.outputs.userAssignedIdentityId}': {}
    }
  }
}

module roleAssignement 'modules/role/roleAssignement.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'roleAssignement'
  params: {
    mediaServiceName: mediaService.outputs.mediaServiceName
    principalId: identity.outputs.userAssignedIdentityPrincipalId
  }
}

module videoIndexer 'modules/videoIndexer/indexer.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'videoIndexer'
  params: {
    location: location
    managedIdentityResourceId: identity.outputs.userAssignedIdentityId    
    mediaServiceAccountResourceId: mediaService.outputs.mediaServiceId
    suffix: suffix
  }
}

module monitoring 'modules/monitoring/monitoring.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'monitoring'
  params: {
    location: location
    suffix: suffix
  }
}

// Create the connection needed for Logic App
module connectionWordOnline 'modules/logicapp/connection.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'connectionWordOnline'
  params: {
    location: location
    displayName: displayName     
  }
}

module servicebus 'modules/servicebus/servicebus.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'servicebus'
  params: {
    location: location
    suffix: suffix
  }
}

module cosmosdb 'modules/cosmosdb/cosmos.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'cosmosdb'
  params: {
    location: location
    suffix: suffix
  }
}

module logicApp 'modules/logicapp/logicApp.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'logicApp'
  params: {
    appInsightName: monitoring.outputs.insightName
    location: location
    storageNameLogicApp: storageLogicApp.outputs.storageName
    storageNameDocument: storageDocument.outputs.storageName
    suffix: suffix
    wordOnlineBusinessConnectionUrl: connectionWordOnline.outputs.wordOnlineEndpointUrl
    videoIdxGetTokenEndpointUrl: videoIndexer.outputs.videoIndexerGetTokenEndpoint
    videoIndexerUploadVideoEndpoint: videoIndexer.outputs.videoIndexerUploadVideoEndpoint
    videoIndexerAccountId: videoIndexer.outputs.videoIndexerAccountId
    cosmosDbName: cosmosdb.outputs.cosmosDbName
    serviceBusName: servicebus.outputs.serviceBusNamespaceName
  }
}

module roleContributorVideoIndexer 'modules/role/contributor.indexer.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'roleContributorVideoIndexer'
  params: {
    principalId: logicApp.outputs.logicAppSystemAssingedIdentityObjecId
    videoIndexerName: videoIndexer.outputs.videoIndexerName
  }
}

module connectionRoleAssignement 'modules/role/connectionAssignement.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'connectionRoleAssignement'
  params: {    
    logicAppSystemAssingedIdentityObjecId: logicApp.outputs.logicAppSystemAssingedIdentityObjecId  
    wordBusinessName: connectionWordOnline.outputs.wordBusinessName
  }
}

output logicAppName string = logicApp.outputs.logicAppName
