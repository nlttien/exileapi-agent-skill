# Rule 04: Standalone Packaging & Release Distribution

When building and releasing executable packages:

### 1. Dual DLL Sync
Compiled plugin DLLs must reside in:
- `Plugins/Compiled/<PluginName>/<PluginName>.dll`
- `Plugins/Compiled/<PluginName>.dll`

Ensure `PostBuild` targets in `.csproj` or scripts in `BUILD_PACKAGE.ps1` copy to both destinations.

### 2. Standalone SingleFile Unpack Mode
- In `SingleFilePackager/Program.cs` and `SingleFilePackager_Boss/Program.cs`, the payload extraction loop must **always** extract and overwrite (`entry.ExtractToFile(destPath, true)`) wrapped in a `try/catch` block.
- This ensures any new build run by the user immediately overwrites existing cached binaries in `%LOCALAPPDATA%\PoE_AutoBoss_Engine` or `%LOCALAPPDATA%\PoE_AutoBuyer_Engine`.

### 3. Release Scripts
- Always execute packaging via:
  - `BUILD_BOSS_PACKAGE.ps1` -> outputs to `dist/AutoBoss_AllInOne.exe`
  - `BUILD_PACKAGE.ps1` -> outputs to `dist/AutoBuyer_AllInOne.exe`
