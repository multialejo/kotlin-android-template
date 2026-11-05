#!/usr/bin/env bash
# Build the app, install it on the running emulator and open it.
set -euo pipefail
cd "$(dirname "$0")/.."

# Must match applicationId in app/build.gradle.kts
APP_ID="com.example.hellokotlin"

if ! docker container inspect android-emulator > /dev/null 2>&1; then
  echo "The emulator isn't running. Start it first with ./scripts/emulator.sh" >&2
  exit 1
fi

bin/android-env ./gradlew installDebug
docker exec android-emulator adb shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
echo "App launched in the emulator."
