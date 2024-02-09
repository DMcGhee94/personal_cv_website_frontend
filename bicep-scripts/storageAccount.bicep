@description('Storage account prefix')
@maxLength(13)
param namePrefix string

@description('Define the name for the storage account')
param storageAccountName string = '${namePrefix}${uniqueString(resourceGroup().id)}'

@description('Define the location the resources should reside in')
param location string = resourceGroup().location

@description('Define the SKU of the resources')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param sku string = 'Standard_LRS'

@description('Define the account type to be created')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param accountKind string = 'StorageV2'

@description('Define the access tier of the account')
@allowed([
  'Cool'
  'Hot'
  'Premium'
])
param accessTier string = 'Hot'

@description('Define if the blob allows public access')
param publicAccessEnabled bool = false

@description('Define if the account allows cross-tenant replication')
param crossTenentReplication bool = false

@description('Define the access tier of the account')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Define if the account will support only HTTPS traffic')
param httpsOnly bool = true

@description('Does the account support hierarchical namespaces?')
param hnsEnabled bool = false

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: accountKind
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: publicAccessEnabled
    allowCrossTenantReplication: crossTenentReplication
    publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: httpsOnly
    isHnsEnabled: hnsEnabled
  }
}

output storageAccountName string = storageAccountName
output websiteEndpoint string = storageAccount.properties.primaryEndpoints.web
