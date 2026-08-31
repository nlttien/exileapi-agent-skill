# .agents/scripts/verify-build-health.ps1
# Runs a comprehensive build test on all ExileApi plugins and single-file packagers

$ErrorActionPreference = 'Stop'
$exileDir = "d:\codecuatien\ExileApi-Compiled"

Write-Host "=== VERIFYING BUILD HEALTH FOR ALL EXILEAPI PROJECTS ===" -ForegroundColor Cyan

$projects = @(
    "Plugins\Source\AutoExile\AutoExile.csproj",
    "Plugins\Source\ShopAutoBuyer\ShopAutoBuyer.csproj",
    "Plugins\Source\ExchangeCollector\ExchangeCollector.csproj",
    "SingleFilePackager\SingleFilePackager.csproj",
    "SingleFilePackager_Boss\SingleFilePackager_Boss.csproj"
)

$hasError = $false

foreach ($projRel in $projects) {
    $projPath = Join-Path $exileDir $projRel
    if (Test-Path $projPath) {
        Write-Host "Building $projRel..." -ForegroundColor Yellow
        $null = dotnet build $projPath -c Release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Build Succeeded: $projRel" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Build Failed: $projRel" -ForegroundColor Red
            $hasError = $true
        }
    } else {
        Write-Host "[WARN] File not found: $projPath" -ForegroundColor Yellow
    }
}

if ($hasError) {
    Write-Host "Build health check completed WITH ERRORS." -ForegroundColor Red
    exit 1
} else {
    Write-Host "ALL PROJECTS BUILT WITH 0 ERRORS!" -ForegroundColor Green
}
