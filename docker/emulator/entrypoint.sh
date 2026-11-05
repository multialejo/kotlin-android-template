#!/usr/bin/env bash
# Start the emulator on the host display, wait for it to boot, and save a snapshot on stop.
set -euo pipefail

AVD_NAME="device"

if [[ -z "${DISPLAY:-}" ]]; then
  echo "ERROR: DISPLAY is not set. Start the emulator with scripts/emulator.sh." >&2
  exit 1
fi

# The AVD lives in a volume, so it is created on first start and reused after that
if [[ ! -f "$ANDROID_AVD_HOME/$AVD_NAME.ini" ]]; then
  echo "Creating AVD $AVD_NAME (Android API $ANDROID_PLATFORM)..."
  echo "no" | avdmanager create avd \
    --name "$AVD_NAME" \
    --package "system-images;android-${ANDROID_PLATFORM};default;x86_64" \
    --device "pixel" > /dev/null
  # Let the computer's keyboard type into the emulator
  echo "hw.keyboard=yes" >> "$ANDROID_AVD_HOME/$AVD_NAME.avd/config.ini"
fi

# Only this container uses the AVD, so lock files left by an unclean stop are stale
find "$ANDROID_AVD_HOME/$AVD_NAME.avd" -maxdepth 1 -name '*.lock' -exec rm -rf {} +

# Quick Boot: restores from the snapshot saved on the last clean shutdown
echo "Starting Android Emulator..."
emulator -avd "$AVD_NAME" -accel on -gpu host -feature -Vulkan -no-audio -no-boot-anim -no-metrics >/tmp/emu.log 2>&1 &
EMU_PID=$!

# Shut down cleanly on Ctrl+C / docker stop so the Quick Boot snapshot gets saved
shutdown() {
  echo "Saving snapshot and stopping emulator..."
  adb emu kill >/dev/null 2>&1 || kill "$EMU_PID" 2>/dev/null || true
  wait "$EMU_PID" 2>/dev/null || true
  exit 0
}
trap shutdown INT TERM

echo "Waiting for emulator to boot..."
SECONDS=0
until adb shell getprop sys.boot_completed 2>/dev/null | grep -q 1; do
  if ! kill -0 "$EMU_PID" 2>/dev/null; then
    echo "ERROR: Emulator exited. Log output:" >&2
    cat /tmp/emu.log >&2
    exit 1
  fi
  if (( SECONDS > 180 )); then
    echo "ERROR: Emulator boot timed out after 180s. Log output:" >&2
    tail -n 50 /tmp/emu.log >&2
    exit 1
  fi
  sleep 2
done
echo "Emulator booted in ${SECONDS}s. Run ./scripts/preview.sh in another terminal."

# wait returns early when a signal arrives, so loop until the emulator exits
while kill -0 "$EMU_PID" 2>/dev/null; do
  wait "$EMU_PID" || true
done
