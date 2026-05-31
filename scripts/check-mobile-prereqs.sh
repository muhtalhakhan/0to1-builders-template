#!/usr/bin/env bash
set -euo pipefail

issues=()
warnings=()

add_issue() {
  local message="$1"
  local fix="$2"
  issues+=("$message|||$fix")
}

add_warning() {
  local message="$1"
  local fix="$2"
  warnings+=("$message|||$fix")
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

path_has_entry() {
  local candidate="$1"
  [ -z "$candidate" ] && return 1
  IFS=':' read -r -a path_entries <<< "${PATH:-}"
  for entry in "${path_entries[@]}"; do
    [ "$entry" = "$candidate" ] && return 0
  done
  return 1
}

print_items() {
  local header="$1"
  shift
  local items=("$@")
  [ "${#items[@]}" -eq 0 ] && return 0

  echo
  echo "$header"
  for item in "${items[@]}"; do
    local message="${item%%|||*}"
    local fix="${item#*|||}"
    echo "- $message"
    if [ -n "$fix" ]; then
      echo "  fix command(s):"
      while IFS= read -r line; do
        echo "  $line"
      done <<< "$fix"
    fi
  done
}

echo "running mobile environment checks..."

flutter_found=1
if ! has_cmd flutter; then
  flutter_found=0
  add_issue \
    "Flutter SDK is not installed or not on PATH (\`flutter\` not found)." \
    "macOS: brew install --cask flutter
Linux: snap install flutter --classic
Then verify: flutter --version"
fi

if ! has_cmd java; then
  add_issue \
    "JDK is not installed or not on PATH (\`java\` not found)." \
    "macOS: brew install --cask temurin@17
Linux (Debian/Ubuntu): sudo apt-get update && sudo apt-get install -y openjdk-17-jdk
Then verify: java -version"
fi

if [ -z "${JAVA_HOME:-}" ]; then
  add_issue \
    "JAVA_HOME is not set." \
    "macOS/Linux example: export JAVA_HOME=\$(/usr/libexec/java_home 2>/dev/null || dirname \$(dirname \$(readlink -f \$(which javac))))
Add it to your shell profile (~/.zshrc or ~/.bashrc)."
elif [ ! -d "$JAVA_HOME" ]; then
  add_issue \
    "JAVA_HOME points to a missing path: $JAVA_HOME" \
    "Set a valid path, then reload shell:
export JAVA_HOME=/path/to/jdk"
fi

android_sdk_path=""
if [ -n "${ANDROID_SDK_ROOT:-}" ]; then
  android_sdk_path="$ANDROID_SDK_ROOT"
elif [ -n "${ANDROID_HOME:-}" ]; then
  android_sdk_path="$ANDROID_HOME"
else
  add_issue \
    "ANDROID_SDK_ROOT or ANDROID_HOME must be set." \
    "macOS/Linux example:
export ANDROID_SDK_ROOT=\$HOME/Android/Sdk
export ANDROID_HOME=\$ANDROID_SDK_ROOT"
fi

if [ -n "${ANDROID_SDK_ROOT:-}" ] && [ -n "${ANDROID_HOME:-}" ] && [ "$ANDROID_SDK_ROOT" != "$ANDROID_HOME" ]; then
  add_warning \
    "ANDROID_SDK_ROOT and ANDROID_HOME are different. Consider aligning them." \
    "export ANDROID_HOME=\$ANDROID_SDK_ROOT"
fi

if [ -n "$android_sdk_path" ] && [ ! -d "$android_sdk_path" ]; then
  add_issue \
    "Android SDK path does not exist: $android_sdk_path" \
    "Set a valid path:
export ANDROID_SDK_ROOT=/actual/sdk/path
export ANDROID_HOME=\$ANDROID_SDK_ROOT"
fi

sdkmanager_found=0
if has_cmd sdkmanager; then
  sdkmanager_found=1
elif [ -n "$android_sdk_path" ] && { [ -f "$android_sdk_path/cmdline-tools/latest/bin/sdkmanager" ] || [ -f "$android_sdk_path/cmdline-tools/latest/bin/sdkmanager.bat" ] || [ -f "$android_sdk_path/cmdline-tools/bin/sdkmanager" ] || [ -f "$android_sdk_path/cmdline-tools/bin/sdkmanager.bat" ]; }; then
  sdkmanager_found=1
fi

if [ "$sdkmanager_found" -ne 1 ]; then
  add_issue \
    "Android SDK command-line tools are missing (\`sdkmanager\` not found)." \
    "1) Download command-line tools from https://developer.android.com/studio#command-tools
2) Extract to \$ANDROID_SDK_ROOT/cmdline-tools/latest
3) export PATH=\$PATH:\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
4) sdkmanager --licenses"
fi

avdmanager_found=0
if has_cmd avdmanager; then
  avdmanager_found=1
elif [ -n "$android_sdk_path" ] && { [ -f "$android_sdk_path/cmdline-tools/latest/bin/avdmanager" ] || [ -f "$android_sdk_path/cmdline-tools/latest/bin/avdmanager.bat" ] || [ -f "$android_sdk_path/cmdline-tools/bin/avdmanager" ] || [ -f "$android_sdk_path/cmdline-tools/bin/avdmanager.bat" ]; }; then
  avdmanager_found=1
fi

if [ "$avdmanager_found" -ne 1 ]; then
  add_issue \
    "Android AVD manager is missing (\`avdmanager\` not found)." \
    "Ensure command-line tools are installed, then export PATH:
export PATH=\$PATH:\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
fi

adb_found=0
if has_cmd adb; then
  adb_found=1
elif [ -n "$android_sdk_path" ] && { [ -f "$android_sdk_path/platform-tools/adb" ] || [ -f "$android_sdk_path/platform-tools/adb.exe" ]; }; then
  adb_found=1
fi

if [ "$adb_found" -ne 1 ]; then
  add_issue \
    "Android platform-tools are missing (\`adb\` not found)." \
    "sdkmanager \"platform-tools\"
export PATH=\$PATH:\$ANDROID_SDK_ROOT/platform-tools"
fi

if [ -n "$android_sdk_path" ]; then
  platform_tools="$android_sdk_path/platform-tools"
  if [ -d "$platform_tools" ] && ! path_has_entry "$platform_tools"; then
    add_issue \
      "PATH is missing Android platform-tools directory." \
      "export PATH=\$PATH:$platform_tools"
  fi

  cmdline_latest="$android_sdk_path/cmdline-tools/latest/bin"
  cmdline_bin="$android_sdk_path/cmdline-tools/bin"
  cmdline_exists=0
  [ -d "$cmdline_latest" ] && cmdline_exists=1
  [ -d "$cmdline_bin" ] && cmdline_exists=1
  if [ "$cmdline_exists" -eq 1 ] && ! path_has_entry "$cmdline_latest" && ! path_has_entry "$cmdline_bin"; then
    add_issue \
      "PATH is missing Android command-line tools directory." \
      "export PATH=\$PATH:$cmdline_latest"
  fi
fi

connected_devices=0
if [ "$adb_found" -eq 1 ]; then
  if adb_output="$(adb devices 2>/dev/null)"; then
    connected_devices="$(printf '%s\n' "$adb_output" | awk '/\tdevice$/{count++} END{print count+0}')"
  else
    add_warning "Could not query connected devices via adb." "Run: adb start-server && adb devices"
  fi
fi

avd_count=0
emulator_found=0
if has_cmd emulator; then
  emulator_found=1
elif [ -n "$android_sdk_path" ] && { [ -f "$android_sdk_path/emulator/emulator" ] || [ -f "$android_sdk_path/emulator/emulator.exe" ]; }; then
  emulator_found=1
fi

if [ "$emulator_found" -eq 1 ]; then
  if avd_output="$(emulator -list-avds 2>/dev/null)"; then
    avd_count="$(printf '%s\n' "$avd_output" | awk 'NF{count++} END{print count+0}')"
  else
    add_warning "Could not list emulators." "Run: emulator -list-avds"
  fi
fi

if [ "$connected_devices" -eq 0 ] && [ "$avd_count" -eq 0 ]; then
  add_issue \
    "No physical device connected and no emulator configured." \
    "Physical device: enable developer options + USB debugging, connect USB, then run: adb devices
Emulator:
sdkmanager \"emulator\" \"system-images;android-34;google_apis;x86_64\"
avdmanager create avd -n pixel34 -k \"system-images;android-34;google_apis;x86_64\"
emulator -avd pixel34"
fi

if [ "$flutter_found" -eq 1 ]; then
  if flutter_doctor="$(flutter doctor -v 2>/dev/null)"; then
    if printf '%s\n' "$flutter_doctor" | grep -E "Android toolchain.*✗" >/dev/null 2>&1; then
      add_warning \
        "Flutter doctor reports Android toolchain issues." \
        "Run:
flutter doctor -v
flutter doctor --android-licenses"
    fi
  else
    add_warning "Could not run flutter doctor for deeper validation." "Run: flutter doctor -v"
  fi
fi

if [ "${#warnings[@]}" -gt 0 ]; then
  print_items "warnings:" "${warnings[@]}"
fi

if [ "${#issues[@]}" -gt 0 ]; then
  print_items "mobile setup check failed:" "${issues[@]}"
  exit 1
fi

echo "mobile environment checks passed."
