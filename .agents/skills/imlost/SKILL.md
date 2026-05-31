---
name: imlost
description: Use when user says $imlost or sounds confused or stuck. Reads current state and offers one clear next step.
triggers:
  - $imlost
---

# imlost

Use this skill when user says `$imlost` or sounds stuck.

## workflow
1. Read current app state and latest intent.
2. Offer one next step with a short reason.
3. Apply that step immediately.
