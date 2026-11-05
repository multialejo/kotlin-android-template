#!/usr/bin/env bash
# Build the debug APK inside the Docker container.
set -euo pipefail
cd "$(dirname "$0")/.."
bin/android-env ./gradlew assembleDebug
echo
echo "APK ready: app/build/outputs/apk/debug/app-debug.apk"
echo "Run it on the emulator: ./scripts/preview.sh"
