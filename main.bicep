param location string = resourceGroup().location

@description('Resource name prefix')
param resourceNamePrefix string = 'FuncAppBicep'
var envResourceNamePrefix = toLower(resourceNamePrefix)

@description('MX record to be used within MTA-STS policy')
param mxRecord string = '*.mail.protection.outlook.com'

resource StorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: '${envResourceNamePrefix}storage'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}
var StorageAccountPrimaryAccessKey = listKeys(StorageAccount.id, StorageAccount.apiVersion).keys[0].value

resource HostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${envResourceNamePrefix}-asp'
  location: location
  kind: 'Windows'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: false
  }
}

resource FunctionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: '${envResourceNamePrefix}-app'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: HostingPlan.id
    reserved: false
    siteConfig: {
      alwaysOn: false
      numberOfWorkers: 1
      http20Enabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${StorageAccount.name};AccountKey=${StorageAccountPrimaryAccessKey};EndpointSuffix=core.windows.net'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
      ]
    }
  }
}

resource HttpTrigger 'Microsoft.Web/sites/functions@2022-03-01' = {
  name: '${FunctionApp.name}/HttpTrigger1'
  properties: {
    language: 'CSharp'
    isDisabled: false
    files: {
      'run.csx': '#r "Newtonsoft.Json"\nusing System.Net;\nusing Microsoft.AspNetCore.Mvc;\nusing Microsoft.Extensions.Primitives;\nusing Newtonsoft.Json;\n\npublic static async Task<IActionResult> Run(HttpRequest req, ILogger log)\n{\n    log.LogInformation("C# HTTP trigger function processed a request.");\n\n    string responseMessage = "version STSv1\\nmode: testing\\nmx: ${mxRecord}\\nmax_age: 604800";\n\n    return new OkObjectResult(responseMessage);\n}'
    }
    config: {
      bindings: [
        {
          name: 'req'
          route: '.well-known/mta-sts.txt'
          authLevel: 'anonymous'
          methods: [
            'get'
          ]
          direction: 'in'
          type: 'httpTrigger'
        }
        {
          name: '$return'
          type: 'http'
          direction: 'out'
        }
      ]
    }
  }
}
