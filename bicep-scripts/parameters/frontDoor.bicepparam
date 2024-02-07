using '../frontDoor.bicep'

param profileName = 'testFrontDoor'

param originHostName = ''

param originPath = ''

param endpointName = 'dmcv-website'

param skuName = 'Standard_AzureFrontDoor'

param subdomain = 'dev'

param domain = 'darren-mcghee.com'

param azureDnsZoneName = 'darren-mcghee.com'
