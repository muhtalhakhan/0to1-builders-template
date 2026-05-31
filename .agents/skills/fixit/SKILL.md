---
name: fixit
description: Use when user says $fixit or asks to repair issues. Checks install state, runs lint/build, and auto-fixes safe problems.
triggers:
  - $fixit
---

# fixit

Use this skill when user says `$fixit` or asks to repair issues.

## workflow
1. Check install state.
2. Run lint/build checks.
3. Auto-fix what is safe.
4. Report plain-language fixes applied.
