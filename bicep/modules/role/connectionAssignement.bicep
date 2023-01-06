param wordBusinessName string
param logicAppSystemAssingedIdentityObjecId string

@description('This is the built-in Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {  
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

resource wordbusiness 'Microsoft.Web/connections@2016-06-01' existing = {
  name: wordBusinessName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: wordbusiness
  name: guid(wordbusiness.id, logicAppSystemAssingedIdentityObjecId, contributorRoleDefinition.id)
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: logicAppSystemAssingedIdentityObjecId
    principalType: 'ServicePrincipal'
  }
}

// resource accessPolicies 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
//   name: '${wordBusinessName}/${logicAppSystemAssingedIdentityObjecId}'
//   location: location
//   properties: {    
//     principal: {
//       type: 'ActiveDirectory'
//       identity: {
//         tenantId: subscription().tenantId
//         objectId: logicAppSystemAssingedIdentityObjecId
//       }
//     }
//   }
// }
