<#
.SYNOPSIS
Exports the most recent failed or risky sign-ins from Microsoft 365 / Azure AD using Microsoft Graph PowerShell.

.ОПИСАНИЕ
Скриптът извлича последните 200 опита за вход, които са се провалили или са задействали Conditional Access правила.
Резултатът се експортира в CSV файл с текуща дата и час в папката "Documents" на потребителя.

.ИЗИСКВАНИЯ
- Microsoft Graph PowerShell SDK
- Разрешения: AuditLog.Read.All, Directory.Read.All
- Активна сесия с Microsoft Graph:
  Connect-MgGraph -Scopes "AuditLog.Read.All","Directory.Read.All"
#>

# Необходимо е първо да се свържеш:
# Connect-MgGraph -Scopes "AuditLog.Read.All","Directory.Read.All"

# Извличане на последните 200 неуспешни или рискови входа
$FailedSignIns = Get-MgAuditLogSignIn -Top 200 |
Where-Object { $_.Status.ErrorCode -ne 0 -or $_.RiskDetail -ne "none" } |
Select-Object `
    UserDisplayName,
    UserPrincipalName,
    @{Name = "Status";   Expression = { $_.Status.FailureReason }},
    @{Name = "App";      Expression = { $_.AppDisplayName }},
    @{Name = "IP";       Expression = { $_.IpAddress }},
    @{Name = "Country";  Expression = { $_.Location.CountryOrRegion }},
    @{Name = "City";     Expression = { $_.Location.City }},
    ConditionalAccessStatus,
    CreatedDateTime

# Експортиране на резултата в CSV файл
$FilePath = "$env:USERPROFILE\Documents\Failed_SignIns_Report_$(Get-Date -Format yyyyMMdd_HHmm).csv"
$FailedSignIns | Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8

# Потвърждение в конзолата
Write-Host "✅ Отчетът е експортиран в: $FilePath" -ForegroundColor Green
