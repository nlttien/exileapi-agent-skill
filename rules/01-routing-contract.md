# Rule 01: Routing Contract & Execution Lifecycle

Every task handled by an agent in this repository must follow a strict, non-improvisational lifecycle:

### Phase 1: Intake & Scope Verification
- Identify which plugin/assembly is affected:
  - `Plugins/Source/AutoExile` -> Bot Core, Exploration, Combat, Boss Encounters, Lab, Simulacrum.
  - `Plugins/Source/ShopAutoBuyer` -> Automated NPC/Player Trading, Stashing, WebSocket client.
  - `Plugins/Source/ExchangeCollector` -> Currency Exchange automation.
  - `SingleFilePackager` / `SingleFilePackager_Boss` -> Standalone packaging engine.

### Phase 2: Knowledge Base Check
- Search `.agents/knowledge-base/FIELD_JOURNAL.md` for existing notes, past regressions, or known gotchas related to the target file.

### Phase 3: Surgical Edit
- Make targeted modifications.
- Preserve XML doc comments, logging statements, and code formatting.
- Avoid introducing breaking changes to shared interfaces (`IBossEncounter`, `IBotMode`, `IBotSubsystem`).

### Phase 4: Compilation Verification
- Run `dotnet build <path-to-csproj>` to confirm `0 Warning(s) / 0 Error(s)` (or standard warning tolerance with 0 errors).

### Phase 5: Mandatory Skill & Knowledge Evolution (Bắt buộc)
- If the task involved a new edge case, new boss timing, new offset structure, or new bug pattern:
  1. **Update `skills/<skill-name>/SKILL.md`**: Directly add the new discovery/rules into the skill playbook.
  2. **Log to `FIELD_JOURNAL.md`**: Record the post-mortem with root cause and prevention rule.
  3. **Sync to `COMMON_PATTERNS.md`**: If a new reusable code pattern was created.
