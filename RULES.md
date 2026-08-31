# Global Rules & Safety Constraints (RULES.md)

This file contains the top-level immutable rules governing agent behavior when working on the **ExileApi** codebase.

---

## 🔒 Rule 1: Memory Access & Pointer Safety
- **Never dereference memory blindly**: Always verify that `Entity`, `Element`, `Component`, or `Camera` is non-null and `IsValid`.
- **Handle Game State Transitions**: Always check `gc.Area.CurrentArea.IsHideout`, `IsTown`, or `IsLoading` before executing in-zone actions.
- **Null Safety in C# 10+**: Maintain `#nullable enable` compliance. Handle nulls explicitly using pattern matching `entity is { IsValid: true }` or null-conditional operators `?.`.

---

## ⚡ Rule 2: Deterministic Pipeline Execution
Always follow the standard 5-step lifecycle:
1. **Analyze**: Read relevant source files and consult `.agents/knowledge-base/FIELD_JOURNAL.md`.
2. **Route**: Match the user request against `.agents/MASTER-ROUTING.md`.
3. **Patch**: Apply targeted, clean modifications preserving existing comments and architecture.
4. **Compile & Verify**: Run `dotnet build` on affected `.csproj` files to guarantee `0 Error(s)`.
5. **Record**: If the fix resolved a subtle bug or updated an offset, record it in `.agents/knowledge-base/FIELD_JOURNAL.md`.

---

## 🛠️ Rule 3: Single-File Packaging Integrity
- When building `.exe` release packages via `BUILD_PACKAGE.ps1` or `BUILD_BOSS_PACKAGE.ps1`:
  - Ensure DLLs are synchronized to both `Plugins/Compiled/<PluginName>/` and `Plugins/Compiled/<PluginName>.dll`.
  - Ensure the unpacker (`SingleFilePackager` / `SingleFilePackager_Boss`) uses unconditional overwrite (`overwrite = true`) so updated binaries take effect immediately on end-user machines.

---

## 🎮 Rule 4: Human-like Input & Bot Protection
- Use non-zero random delays between mouse clicks and keystrokes (typically 30–120ms).
- Never send raw coordinate clicks outside the game window boundary (`gc.Window.GetWindowRectangle()`).
- Always release keys and right-click buttons (`BotInput.ReleaseRightClick()`, `BotInput.ReleaseAllKeys()`) upon boss death or zone transition.
