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
5. **Evolve & Record**: Update the corresponding `SKILL.md` and record the fix in `.agents/knowledge-base/FIELD_JOURNAL.md`.

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

---

## 🧠 Rule 5: Mandatory Continuous Skill & Knowledge Evolution (Bắt buộc cập nhật Skill khi gặp trường hợp mới)

Whenever ANY AI agent encounters or resolves a **new scenario**, including but not limited to:
1. **A newly tuned boss mechanic or encounter timing** (e.g. walk-before-blink delay, specific flask sequence, early/immediate attack, emerging invulnerability states).
2. **A new or shifted PoE game memory offset / DevTree structure**.
3. **A new compiler edge-case, MSBuild quirk, or packaging issue** (e.g. file lock bypass, payload overwrite flags, dual-dll synchronization).
4. **A new navigation stuck pattern or A* pathfinding behavior**.
5. **A new trading, stash tab, or WebSocket exchange interaction**.

### ⚠️ NON-NEGOTIABLE PROTOCOL FOR ALL AGENTS:
Before concluding any task involving a novel fix or pattern, the AI agent **MUST**:
1. **Update the relevant `skills/<skill-name>/SKILL.md`**: Add the new pattern, method, code snippet, or tuning rule directly into the skill documentation so future invocations of that skill immediately possess this capability.
2. **Log a Post-Mortem in `knowledge-base/FIELD_JOURNAL.md`**: Record the Target Component, Symptom, Root Cause, Fix Applied, and Prevention Rule.
3. **Add reusable snippets to `knowledge-base/COMMON_PATTERNS.md`** if the pattern is broadly applicable across multiple plugins.

**Never end a turn without persisting newfound knowledge into the skill library.**
