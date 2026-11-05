#!/usr/bin/env bash
# Start the Android emulator in a container. It opens as a window on your desktop.
#
#   emulator.sh             start it (Ctrl+C stops it and saves its state for a fast next start)
#   emulator.sh --rebuild   rebuild the image (e.g. after editing docker/emulator/)
set -euo pipefail
cd "$(dirname "$0")/.."

IMAGE="android-emulator:latest"

build_image() {
  # The emulator image is built on top of the android-env build image
  docker image inspect android-env:latest > /dev/null 2>&1 || bin/android-env --rebuild
  echo "Building the emulator image (takes a few minutes the first time)..."
  docker build \
    ${ANDROID_PLATFORM:+--build-arg ANDROID_PLATFORM="$ANDROID_PLATFORM"} \
    -t "$IMAGE" docker/emulator
}

if [[ "${1:-}" == "--rebuild" ]]; then
  build_image
  exit 0
fi

if [[ ! -c /dev/kvm ]]; then
  echo "ERROR: /dev/kvm not found. Enable virtualization (KVM) to run the emulator." >&2
  exit 1
fi
if [[ -z "${DISPLAY:-}" ]]; then
  echo "ERROR: DISPLAY is not set. Run this from a terminal in your desktop session." >&2
  exit 1
fi

docker image inspect "$IMAGE" > /dev/null 2>&1 || build_image

# Share the host X server (XWayland on Wayland desktops) and the GPU with the container
display_args=(-e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro)
if [[ -n "${XAUTHORITY:-}" && -f "$XAUTHORITY" ]]; then
  display_args+=(-e XAUTHORITY=/tmp/.Xauthority -v "$XAUTHORITY":/tmp/.Xauthority:ro)
fi
if [[ -d /dev/dri ]]; then
  display_args+=(--device /dev/dri)
  for group in render video; do
    gid="$(getent group "$group" | cut -d: -f3)"
    [[ -n "$gid" ]] && display_args+=(--group-add "$gid")
  done
fi

# The AVD volume keeps the device and its Quick Boot snapshot between runs.
# The stop timeout gives the emulator time to write the snapshot on docker stop.
# Host networking lets adb in the android-env container reach the emulator.
exec docker run --rm -it \
  --name android-emulator \
  --network host \
  --device /dev/kvm \
  --stop-timeout 60 \
  "${display_args[@]}" \
  -v android-emulator-avd:/opt/avd \
  "$IMAGE"
