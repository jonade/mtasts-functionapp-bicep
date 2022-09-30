# Deploy an Azure Function App to host a MTA-STS Policy file

Host a static MTA-STS policy file (mta-sts.txt) to ensure that emails to domain are sent in a secure way.


```powershell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount
```

```powershell
New-AzResourceGroup -Name "MTASTSRG" -Location "westeurope"
New-AzResourceGroupDeployment -ResourceGroupName "MTASTSRG" -TemplateFile ./main.bicep
```