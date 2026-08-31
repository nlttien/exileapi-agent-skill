---
name: trade-buyer-diagnostics
description: >-
  Troubleshooting and automating player/NPC trading, ShopAutoBuyer window interaction,
  StashDepositService, Currency Exchange collector, automated 2-currency batch crafting (Rare + Corrupted verification), and PoE Trade WebSocket live search.
---

# Trade Buyer, AutoCraft & Stash Automation Playbook

## 🔍 When to Use This Skill
- `ShopAutoBuyer` fails to click purchase buttons or parse item prices.
- `StashDepositService` fails to deposit purchased currency or maps into stash tabs / Guild Stash.
- Automated crafting of bought items with Currency #1 (slot 5 - Alchemy) and Currency #2 (slot 26 - Vaal) before guild deposit.
- Ensuring 100% verification that items become **RARE** (`ItemRarity.Rare`) and **CORRUPTED** (`baseComp.isCorrupted`).
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

### 2. AutoCrafting Bought Items (Rare + Corrupted Guaranteed Verification)
When buying invitations or maps in bulk and depositing into Guild Stash:

- **DevTree Slot Navigation**:
  In `StashElement` Currency Tab, currency slots follow the DevTree hierarchy:
  `PathFromRoot: (OpenLeftPanel/StashElement)49->2->0->0->1->1->0->0->1->[SlotIndex]->1`
  - **Slot 5 (Ảnh 1)**: Alchemy / Rare currency $\rightarrow$ applied to all items until `IsItemRare == true`.
  - **Slot 26 (Ảnh 2)**: Vaal / Corrupted currency $\rightarrow$ applied to all items until `IsItemCorrupted == true`.

- **State Verification Logic**:
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
```

- **Sequential Crafting Loop**:
```csharp
// Pass 1: Ensure all items are Rare
var nonRare = allItems.Where(i => !IsItemRare(i.Item?.Item) && !IsItemCorrupted(i.Item?.Item)).ToList();
if (nonRare.Count > 0)
    yield return ApplyCurrencyToTargetItemsRoutine(stashElement, slot1Index, nonRare, craftDelay);

// Pass 2: Ensure all items are Corrupted
var nonCorrupted = allItems.Where(i => !IsItemCorrupted(i.Item?.Item)).ToList();
if (nonCorrupted.Count > 0)
    yield return ApplyCurrencyToTargetItemsRoutine(stashElement, slot2Index, nonCorrupted, craftDelay);
```

### 3. Stash Deposit & Guild Stash Safety
- Always verify the stash tab is open (`gc.IngameState.IngameUi.StashElement.IsVisible` or `GuildStashElement.IsVisible`).
- Check inventory grid bounds before `Ctrl + Click` / `Ctrl + Shift + Click` deposit.
- Add 40–80ms humanized delay between batch item transfers.

### 4. Log Inspection
- Inspect `d:\codecuatien\ExileApi-Compiled\ShopAutoBuyer.log` for trade events and deposit histories.
