---
name: single-file-packager-deployment
description: >-
  Building, packaging, self-extracting, and releasing standalone All-In-One executables
  (AutoBoss_AllInOne.exe, AutoBuyer_AllInOne.exe) into dist/.
---

# Single-File Packager & Release Playbook

## 🔍 When to Use This Skill
- Packaging and publishing new bot releases to `dist/`.
- Fixing issues where new code changes are not reflected in the standalone `.exe`.
- Debugging `SingleFilePackager` payload extraction, caching, and locked files.

---

## 🛠️ Step-by-Step Release Workflow

### 1. Build Standalone Boss Executable
```powershell
powershell -ExecutionPolicy Bypass -File "d:\codecuatien\ExileApi-Compiled\BUILD_BOSS_PACKAGE.ps1"
```
**Output**: `d:\codecuatien\ExileApi-Compiled\dist\AutoBoss_AllInOne.exe`

### 2. Build Standalone Buyer Executable
```powershell
powershell -ExecutionPolicy Bypass -File "d:\codecuatien\ExileApi-Compiled\BUILD_PACKAGE.ps1"
```
**Output**: `d:\codecuatien\ExileApi-Compiled\dist\AutoBuyer_AllInOne.exe`

---

## 🛡️ Critical Packager Rules
1. **Always Overwrite Payload Files**:
   In `SingleFilePackager/Program.cs` and `SingleFilePackager_Boss/Program.cs`:
   ```csharp
   try { entry.ExtractToFile(destPath, true); } catch { /* Ignore locked files */ }
   ```
2. **Dual DLL Copy**:
   Always copy output assemblies to both `Plugins/Compiled/<Name>/` and `Plugins/Compiled/<Name>.dll`.
3. **Clean Temp Package**:
   Always remove stale `payload.zip` and `temp_pkg/` before zipping.
