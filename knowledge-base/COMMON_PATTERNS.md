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

## 3. Asynchronous Safe Keypress Sequence
```csharp
private static async Task PressKeysAsync(params Keys[] keys)
{
    foreach (var k in keys)
    {
        Input.KeyDown(k);
        await Task.Delay(30);
        Input.KeyUp(k);
        await Task.Delay(50);
    }
}
```
