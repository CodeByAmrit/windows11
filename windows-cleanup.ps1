# 05-windows-cleanup.ps1
# Debloat and remove commonly unwanted Store apps and set privacy options where safe
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) { Write-Host "Run as Administrator" -ForegroundColor Red; exit 1 }


Write-Host "Removing selected built-in apps..." -ForegroundColor Cyan
$bloat = @(
"Microsoft.3DBuilder",
"Microsoft.BingNews",
"Microsoft.GetHelp",
"Microsoft.Getstarted",
"Microsoft.Microsoft3DViewer",
"Microsoft.MicrosoftOfficeHub",
"Microsoft.MicrosoftSolitaireCollection",
"Microsoft.MixedReality.Portal",
"Microsoft.People",
"Microsoft.SkypeApp",
"Microsoft.XboxApp",
"Microsoft.WindowsCamera",
"Microsoft.ZuneMusic",
"Microsoft.ZuneVideo"
)


foreach ($p in $bloat) {
Write-Host "Removing Appx: $p"
Get-AppxPackage -Name $p -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object DisplayName -Like "*$p*" | ForEach-Object { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName } 2>$null
}


Write-Host "Cleanup finished. Some apps may reappear after major Windows updates." -ForegroundColor Green