---
name: self-evolving-knowledge-base
description: >-
  Self-evolving knowledge base and field journal management.
  Use to log root causes of fixed bugs, regression patterns, memory offset shifts, and operational learnings.
---

# Self-Evolving Knowledge Base & Field Journal

## 🔍 When to Use This Skill
- A bug is successfully diagnosed and fixed.
- A subtle PoE engine behavior or memory quirk is discovered.
- A new script or packaging rule is established.

---

## 📝 Logging Format in `knowledge-base/FIELD_JOURNAL.md`

Every new entry should follow this structured post-mortem format:

```markdown
### [YYYY-MM-DD] <Short Bug / Topic Description>
- **Target Component**: `AutoExile / EaterEncounter.cs` (or relevant file)
- **Symptom**: Describe what was failing from the user's perspective.
- **Root Cause**: The technical reason why the issue occurred.
- **Fix Applied**: The specific code or configuration change.
- **Prevention Rule**: What future agents must check to avoid regressing this fix.
```

---

## 🔄 Self-Evolution Cycle

```
Identify Problem ──► Diagnose & Fix ──► Verify Build (0 Errors) ──► Log to FIELD_JOURNAL.md ──► Re-use in Future Sessions
```
