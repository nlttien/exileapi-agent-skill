# Common Architectural Patterns in ExileApi (COMMON_PATTERNS.md)

This reference documents proven patterns for memory access, navigation, combat, and ImGui rendering.

---

## 1. Safe Entity Search
```csharp
private Entity? FindBoss(GameController gc)
{
    if (gc.Entities == null) return null;

    foreach (var entity in gc.Entities)
    {
        if (entity == null || !entity.IsValid || entity.Id == gc.Player?.Id) continue;

        var path = entity.Path ?? string.Empty;
        var renderName = entity.RenderName ?? string.Empty;

        if (path.Contains("ConsumeBoss", StringComparison.OrdinalIgnoreCase) ||
            renderName.Contains("Eater of Worlds", StringComparison.OrdinalIgnoreCase))
        {
            var life = entity.GetComponent<Life>();
            if (life != null && life.CurHP > 0 && !entity.IsDead)
            {
                return entity;
            }
        }
    }
    return null;
}
```

---

## 2. World-to-Screen Absolute OS Input
```csharp
var cam = gc.IngameState.Camera;
var windowRect = gc.Window.GetWindowRectangle();
var screenPos = cam.WorldToScreen(worldPos3D);
var absPos = new Vector2(windowRect.X + screenPos.X, windowRect.Y + screenPos.Y);
BotInput.RapidRightClickAt(absPos);
```

---

## 3. Shift + RightClick Batch Currency Crafting
```csharp
// 1. Prime currency on cursor via Shift + RightClick
MouseHelper.FastDirectMove(currencyScreenPos);
Input.KeyDown(Keys.LShiftKey);
Input.RightDown();
Input.RightUp();

// 2. Left-click every target item in player inventory while holding Shift
foreach (var item in inventoryItems)
{
    MouseHelper.FastDirectMove(item.ScreenPos);
    Input.LeftDown();
    Input.LeftUp();
    Thread.Sleep(craftDelayMs);
}
Input.KeyUp(Keys.LShiftKey);
```

---

## 4. DevTree Currency Slot Traversal Pattern
```csharp
// Path: (OpenLeftPanel/StashElement)49->2->0->0->1->1->0->0->1->[SlotIndex]->1
int[] prefixPath = { 49, 2, 0, 0, 1, 1, 0, 0, 1 };
Element? elem = stashElement;
foreach (var idx in prefixPath)
{
    if (elem != null && elem.IsValid && idx < elem.Children.Count)
        elem = elem.Children[idx];
}
var slotElement = elem?.Children[slotIndex]?.Children[1] ?? elem?.Children[slotIndex];
```
