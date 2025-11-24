<#
    Windows 11 Post-Install Setup
    Requirements: Run PowerShell as Administrator
#>

# =====================================================
# 0. ADMIN CHECK
# =====================================================
if (-not ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    Write-Host "Run this script as Administrator!" -ForegroundColor Red
    exit
}

Write-Host "Starting Windows 11 Post-Install Setup..." -ForegroundColor Cyan

# =====================================================
# 1. ENABLE HIGH / ULTIMATE PERFORMANCE
# =====================================================
Write-Host "Configuring Power Plans..."

# Try Ultimate Performance
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null

# Fallback to High Performance if Ultimate not present
if ($LASTEXITCODE -ne 0) {
    powercfg -setactive SCHEME_MIN
}

Write-Host "Power mode set successfully!" -ForegroundColor Green

# =====================================================
# 2. INSTALL ESSENTIAL DEVELOPER SOFTWARE
# =====================================================
Write-Host "Installing software via winget..." -ForegroundColor Yellow

$apps = @(
    "Microsoft.VisualStudioCode",
    "Git.Git",
    "GitHub.GitHubDesktop",
    "Google.Chrome",
    "VideoLAN.VLC",
    "OpenJS.NodeJS",
    "Eugeny.Termius",
    "RARLab.WinRAR",
    "Oracle.MySQLWorkbench"
)

foreach ($app in $apps) {
    Write-Host "Installing: $app" -ForegroundColor Magenta
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
}

# =====================================================
# 3. REMOVE WINDOWS BLOAT / USELESS DEFAULT APPS
# =====================================================
Write-Host "Removing Windows bloat apps..." -ForegroundColor Yellow

$bloat = @(
    "Microsoft.3DBuilder",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.Todos",
    "Microsoft.SkypeApp",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.XboxApp",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.WindowsMaps"
)

foreach ($app in $bloat) {
    Write-Host "Removing: $app" -ForegroundColor Red
    Get-AppxPackage $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# =====================================================
# 4. OPTIONAL PERFORMANCE TWEAKS (DISABLED BY DEFAULT)
# =====================================================
$ENABLE_EXTRA_TWEAKS = $false   # change to $true if you want them enabled

if ($ENABLE_EXTRA_TWEAKS) {

    Write-Host "Applying performance tweaks..." -ForegroundColor Blue

    # Disable Startup Delay
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" `
        /v StartupDelayInMSec /t REG_DWORD /d 0 /f

    # Disable Background Apps
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
        /v GlobalUserDisabled /t REG_DWORD /d 1 /f

    # Visual Effects → Performance Mode
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
        /v VisualFXSetting /t REG_DWORD /d 2 /f
}

# =====================================================
# 5. CLEANUP & DONE
# =====================================================
Write-Host "`nAll tasks completed successfully!" -ForegroundColor Green
Write-Host "Restart your PC to apply all settings." -ForegroundColor Yellow
