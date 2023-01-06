param location string
param suffix string
param storageNameLogicApp string
param storageNameDocument string
param appInsightName string
param wordOnlineBusinessConnectionUrl string
param videoIdxGetTokenEndpointUrl string
param videoIndexerUploadVideoEndpoint string
param videoIndexerAccountId string
param cosmosDbName string
param serviceBusName string

var logicName = 'logic-app-${suffix}'

resource storageLogicApp 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageNameLogicApp
}

resource storageDocument 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageNameDocument
}

resource insight 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightName
}

resource account 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' existing = {
  name: cosmosDbName
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusName
}

var cosmosCnxString = account.listConnectionStrings().connectionStrings[0].connectionString
var listKeysEndpoint = '${serviceBusNamespace.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusCnxString = listKeys(listKeysEndpoint, serviceBusNamespace.apiVersion).primaryConnectionString

resource webFarm 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'plan-${suffix}'
  location: location
  sku: {
    tier: 'WorkflowStandard'
    name: 'WS1'
  }
  kind: 'windows'
}

resource logiapp 'Microsoft.Web/sites@2021-02-01' = {
  name: logicName
  location: location
  kind: 'workflowapp,functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {    
    siteConfig: {
      netFrameworkVersion: 'v4.6'
      appSettings: [
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }       
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }         
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'FUNCTIONS_V2_COMPATIBILITY_MODE'
          value: 'true'
        }     
        {
          name: 'WORKFLOWS_SUBSCRIPTION_ID'
          value: subscription().subscriptionId
        }
        {
          name: 'WORKFLOWS_LOCATION_NAME'
          value: location
        }
        {
          name: 'WORKFLOWS_RESOURCE_GROUP_NAME'
          value: resourceGroup().name
        }
        {
          name: 'AzureBlob_connectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageDocument.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageDocument.id, storageDocument.apiVersion).keys[0].value}'
        }
        {
          name: 'wordonlinebusiness_connection_url'
          value: wordOnlineBusinessConnectionUrl
        }
        {
          name: 'VIDEO_INDEXER_GET_TOKEN_ENDPOINT'
          value: videoIdxGetTokenEndpointUrl
        }
        {
          name: 'VIDEO_INDEXER_UPLOAD_VIDEO'
          value: videoIndexerUploadVideoEndpoint
        }
        {
          name: 'VIDEO_INDEXER_ACCOUNT_ID'
          value: videoIndexerAccountId
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }      
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insight.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: insight.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageLogicApp.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageLogicApp.id, storageLogicApp.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageLogicApp.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageLogicApp.id, storageLogicApp.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'logicapp98'
        }
        {
          name: 'AzureCosmosDB_connectionString'
          value: cosmosCnxString
        }
        {
          name: 'serviceBus_connectionString'
          value: serviceBusCnxString
        }
      ]
      use32BitWorkerProcess: true
    }
    serverFarmId: webFarm.id
    clientAffinityEnabled: false    
  }
}


output logicAppSystemAssingedIdentityObjecId string = logiapp.identity.principalId
output logicAppName string = logiapp.name
