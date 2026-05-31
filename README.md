# 0to1-builders

build your first app with ai. no coding experience needed. seriously.

## what is this?
this is the starter for 0to1-builders - a hands-on build flow where you create a real app with openai codex (an ai that writes code with you). you can start from scratch, choose web or mobile, and ship something real.

this repo is what you use to build yours. it comes pre-configured with structure, ui setup, styling, animations, and codex-ready skills so you can focus on your idea instead of setup.

you need a laptop, a chatgpt account, and an idea. if you do not have an idea yet, the agent will help you pick one.

## who this is for
- complete beginners with zero coding experience
- people with ideas who do not know where to start
- anyone curious about building with ai and ready to try

## Quick Start

### npx (recommended — no install required)
```bash
npx 0to1-builders
```
then follow the prompts: pick a project name and choose web or mobile.

---

### Windows (PowerShell)
Web app:
```powershell
irm https://raw.githubusercontent.com/muhtalhakhan/0to1-builders-template/main/scripts/setup-windows.ps1 | iex
```

Mobile app (Flutter):
```powershell
$env:SCAFFOLD='mobile'; irm https://raw.githubusercontent.com/muhtalhakhan/0to1-builders-template/main/scripts/setup-windows.ps1 | iex
```

### macOS/Linux
Web app:
```bash
curl -fsSL https://raw.githubusercontent.com/muhtalhakhan/0to1-builders-template/main/scripts/setup-unix.sh | bash
```

Mobile app (Flutter):
```bash
SCAFFOLD=mobile curl -fsSL https://raw.githubusercontent.com/muhtalhakhan/0to1-builders-template/main/scripts/setup-unix.sh | bash
```

Mobile setup now validates:
- Flutter SDK
- Android SDK
- Android SDK command-line tools (`sdkmanager`)
- JDK + `JAVA_HOME`
- Android SDK env vars (`ANDROID_SDK_ROOT` or `ANDROID_HOME`)
- Connected device or configured emulator

Manual preflight:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-mobile-prereqs.ps1
```
```bash
bash scripts/check-mobile-prereqs.sh
```

### Mobile Prereqs (No Android Studio IDE)
Required components:
- Flutter SDK
- Android SDK command-line tools
- JDK 17+
- Environment variables (`ANDROID_SDK_ROOT`, `ANDROID_HOME`, `JAVA_HOME`)
- PATH entries for `platform-tools` and `cmdline-tools`
- Physical device (USB debugging) or emulator (AVD)

Windows quick commands (PowerShell example):
```powershell
winget install --id Google.Flutter -e
winget install --id EclipseAdoptium.Temurin.17.JDK -e
setx ANDROID_SDK_ROOT "$env:LOCALAPPDATA\Android\Sdk"
setx ANDROID_HOME "$env:LOCALAPPDATA\Android\Sdk"
setx PATH "$env:PATH;%ANDROID_SDK_ROOT%\platform-tools;%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin"
sdkmanager --licenses
```

macOS/Linux quick commands (example):
```bash
brew install --cask flutter temurin@17
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null || dirname $(dirname $(readlink -f $(which javac))))
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
sdkmanager --licenses
```

## Local Use (from this folder)

```bash
npm install
npm run check
npm run check:flutter
```

## What gets set up
- `AGENTS.md` with project behavior and skill registry
- `.agents/skills/*` local skill packs
- `public/milestones.json` progress state file
- `app/` and `components/` web scaffold
- `scaffolds/flutter-app/` mobile scaffold
- Setup scripts that support `web` and `mobile`

## Notes
- This template avoids external API keys and backend services.
- Flutter deploy is guidance/build-artifacts only; store publishing remains manual.
