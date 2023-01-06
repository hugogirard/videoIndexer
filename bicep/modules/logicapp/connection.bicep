param location string
@secure()
param displayName string

resource wordbusiness 'Microsoft.Web/connections@2016-06-01' = {
  name: 'wordonlinebusiness'
  location: location
  kind: 'V2'  
  properties: {
    displayName: displayName
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/wordonlinebusiness'     
    }   
  }
}

output wordOnlineEndpointUrl string = reference(wordbusiness.id,'2016-06-01','full').properties.connectionRuntimeUrl
output wordBusinessName string = wordbusiness.name
