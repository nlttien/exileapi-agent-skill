# Rule 02: Game Memory Safety & Offset Handling

When reading memory in Path of Exile via ExileCore, memory is volatile and can be deallocated at any moment (e.g., entity despawn, area transition).

### 🛡️ Critical Safety Guidelines

1. **Entity Lifecycle**:
   ```csharp
   // ALWAYS check IsValid and null before reading properties:
   if (entity == null || !entity.IsValid || entity.Id == 0) return;
   ```

2. **Component Access**:
   - `entity.GetComponent<T>()` can return `null` if the entity lacks the component or the offset is outdated.
   - Always null-check components before dereferencing:
   ```csharp
   var life = entity.GetComponent<Life>();
   if (life != null && life.CurHP > 0) { ... }
   ```

3. **Coordinate Transforms**:
   - Grid coordinates (`GridPosNum`, `Vector2` / `Vector2i`) are in tile space (typically 0-600).
   - World coordinates (`PosNum`, `BoundsCenterPosNum`, `Vector3`) are in 3D game world space.
   - Screen coordinates (`Vector2`) are converted via `cam.WorldToScreen(worldPos)`.
   - Always offset screen coordinates by `windowRect.X` and `windowRect.Y` when sending absolute OS input clicks:
   ```csharp
   var screenPos = cam.WorldToScreen(entity.BoundsCenterPosNum);
   var windowRect = gc.Window.GetWindowRectangle();
   var absPos = new Vector2(windowRect.X + screenPos.X, windowRect.Y + screenPos.Y);
   ```
