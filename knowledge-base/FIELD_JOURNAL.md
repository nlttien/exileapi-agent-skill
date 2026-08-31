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
  1. Set `_lastBlinkTime` to current timestamp on zone entrance.
  2. Removed unnecessary 2.0s idle delay in Eater fight sequence.
- **Prevention Rule**: Check boss phase transitions individually per boss type; do not copy state machine delays across different bosses without verifying arena intro mechanics.
