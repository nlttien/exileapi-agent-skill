---
name: trade-buyer-diagnostics
description: >-
  Troubleshooting and automating player/NPC trading, ShopAutoBuyer window interaction,
  StashDepositService, Currency Exchange collector, automated 3-currency batch crafting (Slot 5 Rare -> Slot 11 x2 -> Slot 26 Corrupt + 6-Mod check), and PoE Trade WebSocket live search.
---

# Trade Buyer, AutoCraft & Stash Automation Playbook

## 🔍 When to Use This Skill
- `ShopAutoBuyer` fails to click purchase buttons or parse item prices.
- `StashDepositService` fails to deposit purchased currency or maps into stash tabs / Guild Stash.
- Automated 3-stage crafting of bought items with:
  1. Currency #1 (Slot 5 - Alchemy): Hóa RARE
  2. Currency #2 (Slot 11): Click 2 lần mỗi món
  3. Currency #3 (Slot 26 - Vaal): Ép CORRUPTED
- Ensuring 100% RAM verification:
  - **RARE** (`ItemRarity.Rare`)
  - **CORRUPTED** (`baseComp.isCorrupted`)
  - **6-MODIFIER CORRUPTED** (`IsItemCorrupted && mods.ExplicitMods.Count >= 6` hoặc cấu hình `RequiredModCount`)
- `ExchangeCollector` fails to collect completed orders from Faustus Currency Exchange.
- WebSocket live search disconnects or gets rate-limited by GGG trade servers.

---

## 🛠️ Diagnostics & Implementation

### 1. Purchase Window Detection
```csharp
// Supports both PoE1 and PoE2 PurchaseWindow elements:
var purchaseWindow = gc.IngameState?.IngameUi?.PurchaseWindow;
if (purchaseWindow != null && purchaseWindow.IsVisible)
{
    // Locate target item and perform humanized click
}
```

### 2. AutoCrafting 3-Currency Sequence (Slot 5 -> Slot 11 x2 -> Slot 26 + 6-Mod Scan)
When buying invitations or maps in bulk and depositing into Guild Stash:

- **DevTree Slot Navigation**:
  In `StashElement` Currency Tab, currency slots follow the DevTree hierarchy:
  `PathFromRoot: (OpenLeftPanel/StashElement)49->2->0->0->1->1->0->0->1->[SlotIndex]->1`
  - **Slot 5 (Currency 1)**: Nâng cấp tất cả đồ thành RARE (quét RAM đến khi 100% Rare).
  - **Slot 11 (Currency 2)**: Giữ Shift, click 2 lần trên mỗi món đồ.
  - **Slot 26 (Currency 3)**: Ép CORRUPTED (quét RAM đến khi 100% Corrupted).

- **State & 6-Modifier Verification Logic**:
```csharp
public static bool IsItemRare(Entity? entity)
{
    var mods = entity?.GetComponent<Mods>();
    return mods != null && mods.ItemRarity == ItemRarity.Rare;
}

public static bool IsItemCorrupted(Entity? entity)
{
    var baseComp = entity?.GetComponent<Base>();
    return baseComp != null && baseComp.isCorrupted;
}

public static int GetItemExplicitModCount(Entity? entity)
{
    var mods = entity?.GetComponent<Mods>();
    if (mods == null) return 0;
    if (mods.ExplicitMods != null && mods.ExplicitMods.Count > 0) return mods.ExplicitMods.Count;
    return mods.ItemMods?.Count ?? 0;
}

public static bool IsModCountCorrupted(Entity? entity, int requiredMods = 6)
{
    return IsItemCorrupted(entity) && GetItemExplicitModCount(entity) >= requiredMods;
}
```

- **Sequential 3-Stage Crafting Routine**:
```csharp
// Giai đoạn 1: Slot 5 (hóa Rare)
yield return ApplyCurrencyToTargetItemsRoutine(stashElement, slot1Index, nonRareItems, craftDelay, clicksPerItem: 1);

// Giai đoạn 2: Slot 11 (click 2 lần mỗi món)
yield return ApplyCurrencyToTargetItemsRoutine(stashElement, slot2Index, craftableItems, craftDelay, clicksPerItem: 2);

// Giai đoạn 3: Slot 26 (ép Corrupt)
yield return ApplyCurrencyToTargetItemsRoutine(stashElement, slot3Index, nonCorruptedItems, craftDelay, clicksPerItem: 1);
```

### 3. Stash Deposit & Guild Stash Safety
- Always verify the stash tab is open (`gc.IngameState.IngameUi.StashElement.IsVisible` or `GuildStashElement.IsVisible`).
- Check inventory grid bounds before `Ctrl + Click` / `Ctrl + Shift + Click` deposit.
- Add 40–80ms humanized delay between batch item transfers.

### 4. Log Inspection
- Inspect `d:\codecuatien\ExileApi-Compiled\ShopAutoBuyer.log` for trade events and deposit histories.
