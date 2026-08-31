# .agents/scripts/refresh-tool-index.ps1
# Validates developer toolchain environment for ExileApi development

Write-Host "=== EXILEAPI TOOLCHAIN HEALTH CHECK ===" -ForegroundColor Cyan

# 1. Check .NET SDK
try {
    $dotnetVer = dotnet --version
    Write-Host "[OK] .NET SDK: $dotnetVer" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] .NET SDK not found! Install .NET 10 SDK." -ForegroundColor Red
}

# 2. Check Git
try {
    $gitVer = git --version
    Write-Host "[OK] Git: $gitVer" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Git not found in PATH." -ForegroundColor Yellow
}

# 3. Check ExileApi Core Libraries
$exileDir = "d:\codecuatien\ExileApi-Compiled"
$coreDlls = @("ExileCore.dll", "GameOffsets.dll", "ImGui.NET.dll", "SharpDX.dll")
foreach ($dll in $coreDlls) {
    $dllPath = Join-Path $exileDir $dll
    if (Test-Path $dllPath) {
        Write-Host "[OK] Core Binary Present: $dll" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Missing Core Binary: $dll" -ForegroundColor Red
    }
}

# 4. Check Dist Executables
$distDir = Join-Path $exileDir "dist"
@("AutoBoss_AllInOne.exe", "AutoBuyer_AllInOne.exe") | ForEach-Object {
    $exePath = Join-Path $distDir $_
    if (Test-Path $exePath) {
        $info = Get-Item $exePath
        $sizeMb = [math]::Round($info.Length / 1MB, 1)
        Write-Host "[OK] Release Executable: $_ ($sizeMb MB, Modified: $($info.LastWriteTime))" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Release Executable Missing in dist/: $_" -ForegroundColor Yellow
    }
}

Write-Host "Toolchain verification finished." -ForegroundColor Cyan
