---
name: poe-memory-offset-reversing
description: >-
  Reverse engineering and memory structure inspection for Path of Exile and ExileApi.
  Use when analyzing GameOffsets, DevTree hierarchy, IngameState pointers, Entity Component structures,
  or fixing memory read crashes caused by PoE game updates.
---

# PoE Memory Offset Reversing & Struct Diagnostics

## 🔍 When to Use This Skill
- A new PoE patch breaks entity detection, component reads, or UI element finding.
- DevTree shows unexpected paths or component structures.
- Offsets in `GameOffsets.dll` need verification or updating.
- Memory pointer dereferences throw `NullReferenceException` or `AccessViolationException`.

---

## 🛠️ Step-by-Step Methodology

### 1. Identify Target Entity & Metadata Path
In Path of Exile, every monster, boss, chest, or NPC has a unique `Path` and `RenderName`:
- **Boss Paths**:
  - The Searing Exarch: `Metadata/Monsters/AtlasInvaders/CleansingMonsters/CleansingBoss`
  - The Eater of Worlds: `Metadata/Monsters/AtlasInvaders/ConsumeMonsters/ConsumeBoss`
  - The Maven: `Metadata/Monsters/TheMaven/TheMaven`
  - The Feared / Cortex / Chayula / Uber Elder: See `Modes/BossEncounters/FearEncounter.cs`.

### 2. Inspecting Component Hierarchy
Key components used across AutoExile:
- **`Life`**: Health, energy shield, dead status (`life.CurHP`, `life.MaxHP`, `life.CurES`).
- **`Positioned`**: Grid position, rotation (`GridPosNum.X`, `GridPosNum.Y`).
- **`Render`**: 3D bounds, center position (`BoundsCenterPosNum`).
- **`ObjectMagicProperties`**: Monster rarity (`Rarity == MonsterRarity.Unique`), mod names.
- **`Targetable`**: Whether an entity can be clicked or attacked (`isTargetable`).

### 3. UI Element Traversal Pattern
When locating UI elements in `IngameState.IngameUi`:
```csharp
public static Element? FindElementByText(Element root, string targetText)
{
    if (root == null || !root.IsValid) return null;
    if (root.Text != null && root.Text.Contains(targetText, StringComparison.OrdinalIgnoreCase))
        return root;

    foreach (var child in root.Children)
    {
        var match = FindElementByText(child, targetText);
        if (match != null) return match;
    }
    return null;
}
```

### 4. Resolving Offset Breakages
1. Check `Logs/` for `LoadAssembly -> IOException` or `NullReferenceException`.
2. Inspect `GameOffsets/` and `ExileCore/PoEMemory/` mappings.
3. Use `DevTree` plugin in-game to view real-time memory dumps of the target entity.
