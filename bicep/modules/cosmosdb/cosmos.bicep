param location string
param suffix string

var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

var databaseName = 'case'
var containerName = 'video'

resource account 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  name: 'cosmos-${suffix}'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {    
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-10-15' = {
  name: '${account.name}/${databaseName}'
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-10-15' = {
  name: '${database.name}/${containerName}'
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }      
    }
    options: {
      throughput: 400
    }
  }
}

output cosmosDbName string = account.name
