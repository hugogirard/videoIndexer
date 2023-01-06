param mediaServiceName string
param principalId string

@description('This is the built-in Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}


resource media 'Microsoft.Media/mediaservices@2021-11-01' existing = {
  name: mediaServiceName
}

resource symbolicname 'Microsoft.Authorization/roleAssignments@2022-04-01' = {  
  name: guid(media.id, principalId, contributorRoleDefinition.id)
  scope: media
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinition.id
  }
}
