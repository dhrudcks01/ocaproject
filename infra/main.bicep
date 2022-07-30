param sku string = 'Consumption'
param name string = 'ocaproject2'
param skuCount int = 0
param location string = resourceGroup().location
param loc string = 'krc'
param publisherEmail string = 'dhrudcks01@naver.com'
param publisherName string = 'gyeongchan'
var rg = 'rg-${name}-${loc}'
var fncappname = 'fncapp-${name}-${loc}'

resource st 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'st${name}${loc}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}


resource csplan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'csplan-${name}-${loc}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: false 
  }
}


resource fncapp 'Microsoft.Web/sites@2022-03-01' = {
  name: fncappname
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: csplan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${st.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(st.id, '2021-09-01').keys[0].value}'
        }
      ]
    }
    httpsOnly: true
  }
}


resource wrkspc 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'wrkspc-${name}-${loc}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}


resource appins 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appins-${name}-${loc}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    IngestionMode: 'LogAnalytics'
    Request_Source: 'rest'
    WorkspaceResourceId: wrkspc.id
  }
}


resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: 'apim-${name}-${loc}'
  location: location
  sku: {
    capacity: skuCount
    name: sku
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

output rn string = rg
