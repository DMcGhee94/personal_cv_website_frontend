var dnsZoneName = 'darren-mcghee.online'
var cnameRecordName = 'www'
var dnsRecordTimeToLive = 3600

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: dnsZoneName
  location: 'global'
}

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: cnameRecordName
  properties: {
    TTL: dnsRecordTimeToLive
    CNAMERecord: {
      cname: 'portal.azure.com'
    }
  }
}
