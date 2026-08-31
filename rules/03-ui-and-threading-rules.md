# Rule 03: UI, Direct3D & Threading Model

ExileApi separates game memory reading, background automation logic, and DirectX rendering:

### 1. The Render Loop (`Render()`)
- `Render(BotContext ctx)` executes on the Direct3D overlay render thread at 60–144 FPS.
- **NEVER** perform heavy computations, blocking sleeps (`Thread.Sleep`), network I/O, or game input clicks inside `Render()`.
- Only use `ctx.Graphics.DrawText`, `ctx.Graphics.DrawBox`, or ImGui UI elements in `Render()`.

### 2. The Tick Loop (`Tick()`)
- `Tick(BotContext ctx)` is called per bot engine cycle (typically 10–50ms interval).
- Return `BossEncounterResult.InProgress` or `BossEncounterResult.Complete`.
- Update `Status` property on each state transition for live HUD and WebUI display.

### 3. Asynchronous Tasks & Hotkeys
- For delays (e.g. flask presses), use `async Task` with `await Task.Delay(...)` or timestamp deltas (`(DateTime.Now - _lastActionTime).TotalMilliseconds >= CD`).
- Do not block the main tick thread with synchronous `Thread.Sleep()`.
