---
name: boss-encounter-tuning
description: >-
  Playbook for tuning boss fight state machines, delays, flask sequences, pre-cast attacks,
  and encounter lifecycle in AutoExile (Exarch, Eater, Maven, Feared, King, Oshabi, Saresh).
---

# Boss Encounter Tuning & Phase Machine Playbook

## 🔍 When to Use This Skill
- Tuning boss spawn delays, invulnerability periods, and flask activation timing.
- Adjusting right-click rapid attack intervals or pre-casting coordinates.
- Fixing boss death detection, loot sweep timeouts, or instant hideout exit.

---

## 📋 Boss Encounter Matrix

| Boss Encounter | Arena Center | Delay Strategy | Flask / Attack Timing |
|---|---|---|---|
| **The Searing Exarch** | `(253, 253)` | Wait **2.0s** after arrival | Press 1-2-3-4-5 and attack after 2s invulnerability descent |
| **The Eater of Worlds** | `(379, 282)` | **0.0s delay / -0.5s early** | Walk 0.5s $\rightarrow$ Blink $\rightarrow$ At $\le 40\text{g}$ press 1-2-3-4-5 & attack immediately |
| **The Maven** | `(291, 230)` | Dynamic Phase Machine | Brain blast escape $\rightarrow$ Memory game edge wait $\rightarrow$ Flappy bird DPS |
| **The Feared** | Dynamic | Multi-Boss Orbit | Target highest threat unique $\rightarrow$ Orbit & burst |
| **King of the Mists** | `(120, 120)` | Ritual / Maze | Maze solver $\rightarrow$ Totem dodge $\rightarrow$ DPS |

---

## 🛠️ Key Implementation Patterns

### 1. Rapid Right-Click Attack Interval
```csharp
if ((DateTime.Now - _lastCastTime).TotalMilliseconds >= 120)
{
    _lastCastTime = DateTime.Now;
    BotInput.RapidRightClickAt(targetScreenPos);
}
```

### 2. Full 5 Flask Press
```csharp
private static async Task PressAllFiveFlasksAsync()
{
    Keys[] keys = [Keys.D1, Keys.D2, Keys.D3, Keys.D4, Keys.D5];
    foreach (var k in keys)
    {
        Input.KeyDown(k);
        await Task.Delay(30);
        Input.KeyUp(k);
        await Task.Delay(60);
    }
}
```

### 3. Safe Death Cleanup
```csharp
BotInput.ReleaseRightClick();
BotInput.ReleaseAllKeys();
_isLooting = true;
Status = $"{Name} đã chết — Hoàn thành!";
return BossEncounterResult.Complete;
```
