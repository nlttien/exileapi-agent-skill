---
name: trade-buyer-diagnostics
description: >-
  Troubleshooting and automating player/NPC trading, ShopAutoBuyer window interaction,
  StashDepositService, Currency Exchange collector, and PoE Trade WebSocket live search.
---

# Trade Buyer & Stash Automation Playbook

## 🔍 When to Use This Skill
- `ShopAutoBuyer` fails to click purchase buttons or parse item prices.
- `StashDepositService` fails to deposit purchased currency or maps into stash tabs.
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

### 2. Stash Deposit Safety
- Always verify the stash tab is open (`gc.IngameState.IngameUi.StashElement.IsVisible`).
- Check inventory grid bounds before `Ctrl + Click` deposit.
- Add 40–80ms humanized delay between batch item transfers.

### 3. Log Inspection
- Inspect `d:\codecuatien\ExileApi-Compiled\ShopAutoBuyer.log` for trade events and deposit histories.
