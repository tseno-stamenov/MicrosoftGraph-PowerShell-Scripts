# Get Disabled Users with Licenses - Microsoft Graph PowerShell
# Author: Tseno Stamenov
# Requires: Microsoft.Graph module

Connect-MgGraph -Scopes "Directory.Read.All"
$skuMap=@{}; Get-MgSubscribedSku -All | % { $skuMap[[string]$_.SkuId]=$_.SkuPartNumber }
Get-MgUser -All -Filter "accountEnabled eq false" -Property "displayName,userPrincipalName,assignedLicenses" |
 ? { $_.AssignedLicenses.Count -gt 0 } |
 select DisplayName,UserPrincipalName,@{n="Licenses";e={ ($_.AssignedLicenses|%{ $skuMap[[string]$_.SkuId] }) -join ";" }} |
 ft -auto

# Изкарва всички Users който са Disabled и имат поне 1 Active License. 
# Супер кратък скрипт който може да се пусне директно през PowerShell конзолата - Първо Connect-MgGraph -Scopes "Directory.Read.All" - правиш си връзката със Azure и после се поставя долното парче код което ти вади резултати директно във конзолата. 
