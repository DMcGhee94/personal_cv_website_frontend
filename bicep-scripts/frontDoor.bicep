@description('The host name that should be used when connecting to the origin.')
param originHostName string

@description('The path that should be used when connecting to the origin.')
param originPath string = ''

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param endpointName string

@description('The name of the SKU to use when creating the Front Door profile. If you use Private Link this must be set to `Premium_AzureFrontDoor`.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string

@description('The protocol that should be used when connecting from Front Door to the origin.')
@allowed([
  'HttpOnly'
  'HttpsOnly'
  'MatchRequest'
])
param originForwardingProtocol string = 'HttpsOnly'

@description('If you are using Private Link to connect to the origin, this should specify the resource ID of the Private Link resource (e.g. an App Service application, Azure Storage account, etc). If you are not using Private Link then this should be empty.')
param privateEndpointResourceId string = ''

@description('If you are using Private Link to connect to the origin, this should specify the resource type of the Private Link resource. The allowed value will depend on the specific Private Link resource type you are using. If you are not using Private Link then this should be empty.')
param privateLinkResourceType string = ''

@description('If you are using Private Link to connect to the origin, this should specify the location of the Private Link resource. If you are not using Private Link then this should be empty.')
param privateEndpointLocation string = ''

// When connecting to Private Link origins, we need to assemble the privateLinkOriginDetails object with various pieces of data.
var isPrivateLinkOrigin = (privateEndpointResourceId != '')
var privateLinkOriginDetails = {
  privateLink: {
    id: privateEndpointResourceId
  }
  groupId: (privateLinkResourceType != '') ? privateLinkResourceType : null
  privateLinkLocation: privateEndpointLocation
  requestMessage: 'Please approve this connection.'
}

param profileName string 
var originGroupName = 'MyOriginGroup'
var originName = 'MyOrigin'
var routeName = 'MyRoute'

param domain string

param subdomain string

param azureDnsZoneName string

var customDomainName = empty(subdomain) ? domain : subdomain

var dnsRecordTimeToLive = 3600

resource profile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: skuName
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  name: endpointName
  parent: profile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: originGroupName
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: originName
  parent: originGroup
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
    sharedPrivateLinkResource: isPrivateLinkOrigin ? privateLinkOriginDetails : null
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: routeName
  parent: endpoint
  dependsOn: [
    origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    originPath: any(originPath != '' ? originPath : null)
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: originForwardingProtocol
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: azureDnsZoneName
  scope: resourceGroup('dns-zone')
}

resource customDomain 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = {
  name: replace(customDomainName, '.', '-')
  parent: profile
  properties: {
    hostName: empty(subdomain) ? domain : '${subdomain}.${domain}'
    azureDnsZone: dnsZone
    tlsSettings: {
      minimumTlsVersion: 'TLS12'
      certificateType: 'ManagedCertificate'
    }
  }
}

resource cname 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: customDomainName
  parent: dnsZone
  properties: {
    TTL: dnsRecordTimeToLive
    CNAMERecord: {
      cname: endpoint.properties.hostName
    }
  }
}

resource txt 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  name: customDomainName
  parent: dnsZone
  properties: {
    TTL: dnsRecordTimeToLive
    TXTRecords: [
      {
        value: [
          customDomain.properties.validationProperties.validationToken
        ]
      }
    ]
  }
}

output frontDoorEndpointHostName string = endpoint.properties.hostName
output frontDoorId string = profile.properties.frontDoorId
