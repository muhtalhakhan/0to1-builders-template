---
name: start
description: Use when user says $start or asks to begin building their app. Guides them through choosing web vs mobile, locking an idea, and creating the first screen.
triggers:
  - $start
---

# start

Use this skill when user says `$start` or asks to begin.

## workflow
1. Ask what they want to build first: `web app` or `mobile app`.
2. If `web app`, continue in this root project using `app/` and `components/`.
3. If `mobile app`, switch context to `scaffolds/flutter-app/`.
4. Ask for a one-line idea and confirm: "i'm building ___".
5. Create the first visible screen fast in the chosen scaffold.
6. Mark `idea_locked` then `first_screen` in milestones when available.
