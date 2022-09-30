# Deploy an Azure Function App to host a MTA-STS Policy file

Host a static [MTA-STS](https://techcommunity.microsoft.com/t5/exchange-team-blog/introducing-mta-sts-for-exchange-online/ba-p/3106386) policy file at https://mta-sts.contoso.com/.well-known/mta-sts.txt to ensure that emails to the domain are sent securely.

```powershell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount
```

```powershell
New-AzResourceGroup -Name "MTASTSRG" -Location "westeurope"
New-AzResourceGroupDeployment -ResourceGroupName "MTASTSRG" -TemplateFile ./main.bicep
```