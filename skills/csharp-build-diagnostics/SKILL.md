---
name: csharp-build-diagnostics
description: >-
  Diagnostics and repair procedures for .NET 10, C# compiler errors, MSBuild issues,
  and dependency resolution across ExileApi plugins and executables.
---

# C# & MSBuild Diagnostics Playbook

## 🔍 When to Use This Skill
- `dotnet build` returns non-zero exit code or compiler errors.
- Target framework (`net10.0-windows`) or Windows Forms dependencies fail to resolve.
- Obsolete API warnings (e.g. `CS0618: HotkeyNode is obsolete`) need clean refactoring.
- Nullability warnings (`CS8602`, `CS8604`) or unused fields need cleanup.

---

## 🛠️ Step-by-Step Build Verification

### 1. Build Single Plugin
```powershell
# Build AutoExile:
dotnet build "d:\codecuatien\ExileApi-Compiled\Plugins\Source\AutoExile\AutoExile.csproj" -c Release

# Build ShopAutoBuyer:
dotnet build "d:\codecuatien\ExileApi-Compiled\Plugins\Source\ShopAutoBuyer\ShopAutoBuyer.csproj" -c Release

# Build ExchangeCollector:
dotnet build "d:\codecuatien\ExileApi-Compiled\Plugins\Source\ExchangeCollector\ExchangeCollector.csproj" -c Release
```

### 2. Common Compiler Errors & Fixes
- **`CS8602: Dereference of a possibly null reference`**:
  - Add null check: `if (entity?.GetComponent<Life>() is { } life && life.CurHP > 0)`
- **`CS0618: Use Values instead / Merged with PurchaseWindow`**:
  - Update deprecated property access to newer ExileCore API surfaces.
- **`IOException: The process cannot access the file ... because it is being used by another process`**:
  - Run `d:\codecuatien\ExileApi-Compiled\KILL_ALL_BOTS.bat` or terminate existing `Loader.exe` / `AutoBoss.exe` processes before rebuilding.
