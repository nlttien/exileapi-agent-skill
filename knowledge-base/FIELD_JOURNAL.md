# Field Journal & Bug Post-Mortem Registry (FIELD_JOURNAL.md)

This log preserves real bug fixes, memory behaviors, and architectural solutions across development sessions.

---

### [2026-08-31] Teleport Lock During Stash Deposit & Crafting
- **Target Component**: `Plugins/Source/ShopAutoBuyer/Core/Services/PoeLiveTradeCoordinator.cs` & `ShopAutoBuyer.cs`
- **Symptom**: While the bot was in Hideout crafting items or depositing them into Guild Stash, WebSocket live search detected a trade and immediately triggered `/hideout {sellerChar}` (or Direct Travel token), interrupting the stash interaction.
- **Root Cause**: `HandleItemEvaluationAndTravelAsync` loop in `PoeLiveTradeCoordinator` checked `gc.IsLoading` and free slots, but neglected `_isBusyProvider()` (`_stashDepositService.IsDepositing`).
- **Fix Applied**:
  1. Added `_isBusyProvider()` into the pre-travel wait loop: strictly pauses travel until deposit/crafting coroutines complete.
  2. Added safety guard in `ShopAutoBuyer.cs` `_onSellerTargeted` callback to drop teleport commands whenever `_stashDepositService.IsDepositing == true`.
- **Prevention Rule**: All async travel coordinators must check `_isBusyProvider()` / `IsDepositing` before sending chat commands or triggering party teleports.

---

### [2026-08-31] Automated 2-Currency Batch Crafting Before Guild Stash Deposit
- **Target Component**: `Plugins/Source/ShopAutoBuyer/Core/Services/StashDepositService.cs` & `ShopAutoBuyerSettings.cs`
- **Symptom**: Items bought in bulk were deposited directly into Guild Stash in raw uncrafted states without applying required crafting currencies.
- **Root Cause**: Need a sequential 2-stage batch crafting routine to apply Currency #1 (Slot 5) across ALL items in inventory first, then apply Currency #2 (Slot 26) across ALL items before opening Guild Stash.
- **Fix Applied**:
  1. Resolved DevTree slot paths `PathFromRoot: (OpenLeftPanel/StashElement)49->2->0->0->1->1->0->0->1->[SlotIndex]->1` for Slot 5 and Slot 26.
  2. Implemented `ExecuteAutoCraftRoutine()`: opens Personal Stash, switches to `curr` tab, applies Shift+RightClick on Slot 5 -> Left-Click all inventory items, then Shift+RightClick on Slot 26 -> Left-Click all inventory items.
  3. Seamlessly integrated before opening Guild Stash in `ExecuteDepositCoroutine()`. Added hotkey `F9` and HUD button `[🔨 TEST AUTO CRAFT (F9)]`.
- **Prevention Rule**: Always perform AutoCraft in Personal Stash (`curr` tab) first before switching to Guild Stash, and hold Shift to minimize mouse movements during batch item clicks.

---

### [2026-08-31] Eater of Worlds Movement & Timing Optimization
- **Target Component**: `Plugins/Source/AutoExile/Modes/BossEncounters/EaterEncounter.cs`
- **Symptom**: Bot was instantly blinking on the 1st tick upon entering zone, and had a 2.0s wait delay upon reaching the boss arena.
- **Root Cause**:
  1. Blink cooldown was initialized to `DateTime.MinValue`, causing instant blink at spawn before player character settled.
  2. Boss phase 2 had a `2.0s` wait timer copied from Exarch, whereas Eater of Worlds emerges immediately without the long invulnerability descent of Exarch.
- **Fix Applied**:
  1. Added a 500ms walk check (`walkElapsedMs >= 500`) before triggering `Q` (Blink) upon map entry.
  2. Removed post-arrival delay completely: as soon as player reaches $\le 40\text{g}$ from Eater, it triggers 5 flasks and immediately rapid-attacks the center spawn position to hit the boss upon emergence (-0.5s early).
- **Prevention Rule**: Searing Exarch requires a 2.0s wait delay due to sky descent animation; Eater of Worlds must attack immediately without wait delay.

---

### [2026-08-31] SingleFilePackager Stale DLL Extraction Bug
- **Target Component**: `SingleFilePackager/Program.cs` & `SingleFilePackager_Boss/Program.cs`
- **Symptom**: After rebuilding `AutoExile.dll` and running `BUILD_BOSS_PACKAGE.ps1`, launching `AutoBoss_AllInOne.exe` did not run the newest code changes.
- **Root Cause**: Unpacker in `Program.cs` had `if (!File.Exists(destPath) || new FileInfo(destPath).Length != entry.Length)`, which skipped extracting the DLL into `%LOCALAPPDATA%\PoE_AutoBoss_Engine` if the file size remained unchanged.
- **Fix Applied**: Replaced conditional check with unconditional extraction `try { entry.ExtractToFile(destPath, true); } catch { }` so every launch forces the newest payload. Also synchronized DLL copying in build scripts to both `Plugins/Compiled/<PluginName>/` and `Plugins/Compiled/<PluginName>.dll`.
- **Prevention Rule**: Always use `overwrite = true` for self-extracting payload archives in single-file distributions.
