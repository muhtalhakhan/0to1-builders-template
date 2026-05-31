---
name: deploy
description: Use when user says $deploy or asks to put their app online. Verifies build, deploys via Vercel CLI, and returns the live URL.
triggers:
  - $deploy
---

# deploy

Use this skill when user says `$deploy` or asks to put app online.

## workflow
1. Confirm this flow is for web apps in this root scaffold.
2. Verify local build succeeds.
3. Deploy with Vercel CLI.
4. Return live URL.
5. Mark `deployed` and later `shared` when user confirms sharing.
