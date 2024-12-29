param(
    [Parameter(Mandatory=$true)]
    [string]$NewVersion
)

# Validate version format (x.x.x)
if ($NewVersion -notmatch '^\d+\.\d+\.\d+$') {
    Write-Error "Invalid version format. Please use x.x.x format (e.g., 1.0.0)"
    exit 1
}

$ErrorActionPreference = "Stop"
$rootDir = Split-Path -Parent $PSScriptRoot

# Function to backup a file before modifying
function Backup-File {
    param([string]$FilePath)
    Copy-Item $FilePath "$FilePath.bak" -Force
}

# Function to restore a file from backup
function Restore-File {
    param([string]$FilePath)
    if (Test-Path "$FilePath.bak") {
        Move-Item "$FilePath.bak" $FilePath -Force
    }
}

# Files to update
$pubspecPath = Join-Path $rootDir "pubspec.yaml"
$appInfoPath = Join-Path $rootDir "macos/Runner/Configs/AppInfo.xcconfig"
$updateServicePath = Join-Path $rootDir "lib/services/update_service.dart"

# Backup files
Backup-File $pubspecPath
Backup-File $appInfoPath
Backup-File $updateServicePath

try {
    # Update pubspec.yaml
    Write-Host "Updating pubspec.yaml..."
    $pubspec = Get-Content $pubspecPath -Raw
    $pubspec = $pubspec -replace 'version: \d+\.\d+\.\d+', "version: $NewVersion"
    Set-Content $pubspecPath $pubspec

    # Update AppInfo.xcconfig
    Write-Host "Updating AppInfo.xcconfig..."
    $appInfo = Get-Content $appInfoPath -Raw
    $appInfo = $appInfo -replace 'FLUTTER_BUILD_NAME=\d+\.\d+\.\d+', "FLUTTER_BUILD_NAME=$NewVersion"
    Set-Content $appInfoPath $appInfo

    # Update update_service.dart
    Write-Host "Updating update_service.dart..."
    $updateService = Get-Content $updateServicePath -Raw
    $updateService = $updateService -replace 'static const String appVersion = ''\d+\.\d+\.\d+'';', "static const String appVersion = '$NewVersion';"
    Set-Content $updateServicePath $updateService

    # Clean up backups
    Remove-Item "$pubspecPath.bak"
    Remove-Item "$appInfoPath.bak"
    Remove-Item "$updateServicePath.bak"

    Write-Host "`nVersion bump complete!" -ForegroundColor Green
    Write-Host "New version $NewVersion has been set in:"
    Write-Host "- pubspec.yaml"
    Write-Host "- AppInfo.xcconfig"
    Write-Host "- update_service.dart"
    Write-Host "`nPlease run 'flutter clean && flutter pub get' to ensure all changes are applied."

} catch {
    Write-Host "`nError occurred while updating version numbers:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    
    # Restore backups
    Write-Host "`nRestoring files from backup..." -ForegroundColor Yellow
    Restore-File $pubspecPath
    Restore-File $appInfoPath
    Restore-File $updateServicePath
    
    Write-Host "Files have been restored to their original state." -ForegroundColor Yellow
    exit 1
} 