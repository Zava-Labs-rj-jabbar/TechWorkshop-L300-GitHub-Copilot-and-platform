// yaml-language-server: $schema=https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#
param environmentName string = 'dev'
param location string = 'westus3'

var resourceToken = uniqueString(subscription().id, resourceGroup().id, location, environmentName)

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'azuami${resourceToken}'
  location: location
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'azai${resourceToken}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'azasp${resourceToken}'
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    reserved: true // Linux
  }
}

// Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: 'azacr${resourceToken}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
  }
}

// Update App Service with container configuration
resource appServiceWithContainer 'Microsoft.Web/sites@2022-03-01' = {
  name: 'azasv${resourceToken}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/zavastorefront:latest'
      cors: {
        allowedOrigins: ['*']
      }
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistry.properties.loginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistry.listCredentials().username
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
      ]
    }
  }
  tags: {
    'azd-service-name': 'zavastorefront'
  }
}

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-01-01-preview' = {
  name: 'aih${resourceToken}'
  location: location
  kind: 'hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'ZavaStorefront AI Hub'
    publicNetworkAccess: 'Enabled'
  }
}

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-01-01-preview' = {
  name: 'aip${resourceToken}'
  location: location
  kind: 'project'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'ZavaStorefront AI Project'
    hubResourceId: aiHub.id
    publicNetworkAccess: 'Enabled'
  }
}

//resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//name: 'diag-${appService.name}'
 // scope: appService
 // properties: {
 //   workspaceId: '/subscriptions/5368b2d9-6684-421e-919a-cf0d7be0b6a3/resourceGroups/techworkshop-ghcopilot-rg/providers/Microsoft.OperationalInsights/workspaces/logs-ws-prod' // Set Log Analytics Workspace if needed
 //   logs: []
 //   metrics: []
 // }
//}

output RESOURCE_GROUP_ID string = resourceGroup().id
output CONTAINER_REGISTRY_NAME string = containerRegistry.name
output CONTAINER_REGISTRY_LOGIN_SERVER string = containerRegistry.properties.loginServer
output APP_SERVICE_NAME string = appServiceWithContainer.name
output AI_HUB_ID string = aiHub.id
output AI_PROJECT_ID string = aiProject.id
output MANAGED_IDENTITY_ID string = uami.id
