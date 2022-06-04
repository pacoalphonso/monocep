param APPSERVICENAME string

resource appServiceAppSettingsa 'Microsoft.Web/sites/siteextensions@2016-08-01' = {
  name: '${APPSERVICENAME}/Microsoft.ApplicationInsights.AzureWebSites'
}
