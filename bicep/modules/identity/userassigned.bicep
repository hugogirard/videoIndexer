param location string
param suffix string

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'media-ident-${suffix}'
  location: location
}

output userAssignedIdentityId string = userIdentity.id
output userAssignedIdentityClientId string = userIdentity.properties.clientId
output userAssignedIdentityPrincipalId string = userIdentity.properties.principalId
