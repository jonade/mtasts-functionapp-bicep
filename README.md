# Deploy an Azure Function App to host a MTA-STS Policy file

Host a static [MTA-STS](https://techcommunity.microsoft.com/t5/exchange-team-blog/introducing-mta-sts-for-exchange-online/ba-p/3106386) policy file at https://mta-sts.contoso.com/.well-known/mta-sts.txt to ensure that emails to the domain are sent securely.

The app will be created to host a policy which is in `testing` mode first. Later this should be changed to `enforce` mode to ensure that protections start being applied to incoming emails. 

![Map of Function App resources](https://i.imgur.com/ipItmyj.png)

```powershell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount
```

```powershell
New-AzResourceGroup -Name "MTASTSRG" -Location "westeurope"
New-AzResourceGroupDeployment -ResourceGroupName "MTASTSRG" -TemplateFile ./main.bicep

# Or pass it a custom prefix name:
New-AzResourceGroupDeployment -ResourceGroupName "MTASTSRG" -TemplateFile ./main.bicep -resourceNamePrefix "ContosoMtaSts"

# Or use a different MX record within the mta-sts.txt policy instead of the default *.mail.protection.outlook.com
New-AzResourceGroupDeployment -ResourceGroupName "MTASTSRG" -TemplateFile ./main.bicep -mxRecord "mail.contoso.com"
```

or

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjonade%2Fmtasts-functionapp-bicep%2Fmain%2Fazuredeploy.json)