# Field Journal & Bug Post-Mortem Registry (FIELD_JOURNAL.md)

This log preserves real bug fixes, memory behaviors, and architectural solutions across development sessions.

### [2026-08-31] Escape Menu Popup Prevention & Full Inventory Space Handling
- **Target Component**: `Plugins/Source/ShopAutoBuyer/Core/Services/PurchaseExecutor.cs`, `InventorySpaceChecker.cs`, `StashDepositService.cs`, `ShopAutoBuyer.cs`
- **Symptom**: When player inventory became 100% full, the bot pressed Escape repeatedly, opening the Pause / Escape Menu (`RESUME GAME`, `OPTIONS`...), which blocked all in-game mouse and keyboard clicks.
- **Root Cause**:
  1. `InventorySpaceChecker.HasSpaceForItem` relied on `InventoryPanel.IsVisible` (which is false when Shop UI is open), causing it to falsely report free space and attempt Ctrl+Click buy on a full inventory.
  2. `PurchaseExecutor.finally`, `ShopAutoBuyer.Tick()`, and `StashDepositService` each sent `Keys.Escape` without checking if the previous Escape had already closed the UI. The 2nd Escape immediately opened the Game Pause Menu.
- **Fix Applied**:
  1. `InventorySpaceChecker` now checks `ServerInventory.InventSlotItem` grid coordinates directly, accurately detecting 0 free slots.
  2. Added `MouseHelper.IsEscapeMenuOpen(gc)` and `MouseHelper.CloseEscapeMenuIfOpen(gc)` to auto-detect and close the Escape Menu immediately.
  3. Removed redundant `Escape` presses in `PurchaseExecutor.finally`, `ShopAutoBuyer.cs`, and `StashDepositService.cs`.
- **Prevention Rule**: Never fire unverified `Keys.Escape` in multiple consecutive layers. Always verify `IsEscapeMenuOpen` and current UI state before sending keypresses.

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

---

### [2026-08-31] AutoCraft & Stash Navigation Stalling Fix (Off-Screen Stash & Missing Guild Stash Fallback)
- **Target Component**: `Plugins/Source/ShopAutoBuyer/Core/Services/StashDepositService.cs` & `ShopAutoBuyer.cs`
- **Symptom**: When inventory was full, the bot stood still in Hideout without crafting or depositing, logging `[WARN] [CẢNH BÁO] Không thể mở cửa sổ rương GUILD STASH` repeatedly in a fast restart loop.
- **Root Cause**:
  1. `FindStashEntity(true)` returned `null` when no Guild Stash entity was placed in Hideout (only Personal Stash existed), causing `EnsureStashOpenRoutine` to fail all 15 attempts.
  2. When Stash / Guild Stash was off-screen (e.g. character standing near Faustus), `Camera.WorldToScreen` returned coordinates outside the window viewport, resulting in no mouse clicks and zero character movement.
  3. `ShopAutoBuyer.Tick()` restarted `StartDepositCoroutine()` on every frame when deposit failed, creating an infinite 0ms restart loop that locked the travel coordinator in `Trang thai: Đang Craft đồ / Cất rương Guild — Tạm dừng Travel...`.
- **Fix Applied**:
  1. **Automatic Fallback**: If `FindStashEntity(true)` returns null, it immediately falls back to `FindStashEntity(false)` (Personal Stash) with an alert log, preventing hard lock.
  2. **Off-Screen Navigation**: Clamped `Camera.WorldToScreen` coordinates within viewport bounds `[150, Width-150]` when clicking 3D stash entities, commanding the character to walk towards off-screen stashes until they become visible and open.
  3. **Deposit Throttling**: Added a 2.5s retry throttle (`_lastDepositAttemptTime`) in `ShopAutoBuyer.cs` to prevent infinite per-frame restart loops on failed deposits.
- **Prevention Rule**: Always implement coordinate clamping for 3D interactable entities to allow natural character pathfinding towards off-screen targets, and always provide graceful fallbacks between Guild Stash and Personal Stash.
