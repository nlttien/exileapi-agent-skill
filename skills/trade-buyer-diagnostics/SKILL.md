---
name: trade-buyer-diagnostics
description: >-
  Troubleshooting and automating player/NPC trading, ShopAutoBuyer window interaction,
  StashDepositService, Currency Exchange collector, automated 2-currency batch crafting, and PoE Trade WebSocket live search.
---

# Trade Buyer, AutoCraft & Stash Automation Playbook

## 🔍 When to Use This Skill
- `ShopAutoBuyer` fails to click purchase buttons or parse item prices.
- `StashDepositService` fails to deposit purchased currency or maps into stash tabs / Guild Stash.
- Automated crafting of bought items with Currency #1 (slot 5) and Currency #2 (slot 26) before guild deposit.
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

### 2. AutoCrafting Bought Items Before Guild Stash Deposit
When buying items in bulk and depositing into Guild Stash, items often need sequential modification using 2 currencies (e.g. Scour -> Alch, or Chisel -> Alch):

- **DevTree Slot Navigation**:
  In `StashElement` Currency Tab, currency slots follow the DevTree hierarchy:
  `PathFromRoot: (OpenLeftPanel/StashElement)49->2->0->0->1->1->0->0->1->[SlotIndex]->1`
  - **Slot 5 (Ảnh 1)**: First currency used on ALL items in inventory.
  - **Slot 26 (Ảnh 2)**: Second currency used on ALL items in inventory.

```csharp
// Shift + Right Click on Currency slot to prime cursor:
Input.KeyDown(Keys.LShiftKey);
Input.RightDown();
Input.RightUp();

// Keep Shift held and Left-Click every target item in player inventory:
foreach (var target in targetItems)
{
    MouseHelper.FastDirectMove(target.Pos);
    Input.LeftDown();
    Input.LeftUp();
    Thread.Sleep(craftDelayMs);
}
Input.KeyUp(Keys.LShiftKey);
```

### 3. Stash Deposit & Guild Stash Safety
- Always verify the stash tab is open (`gc.IngameState.IngameUi.StashElement.IsVisible` or `GuildStashElement.IsVisible`).
- Check inventory grid bounds before `Ctrl + Click` / `Ctrl + Shift + Click` deposit.
- Add 40–80ms humanized delay between batch item transfers.

### 4. Log Inspection
- Inspect `d:\codecuatien\ExileApi-Compiled\ShopAutoBuyer.log` for trade events and deposit histories.
