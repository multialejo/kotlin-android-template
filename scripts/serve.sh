#!/usr/bin/env bash
# Serve the APK on your Wi-Fi so your phone can download and install it.
# Stop it with Ctrl+C.
set -euo pipefail
cd "$(dirname "$0")/.."
PORT="${PORT:-8000}"
APK=app/build/outputs/apk/debug/app-debug.apk

if [[ ! -f "$APK" ]]; then
  echo "No APK found. Run ./scripts/build.sh first." >&2
  exit 1
fi

mkdir -p dist
cp "$APK" dist/hello-kotlin.apk
cat > dist/index.html <<HTML
<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Hello Kotlin</title>
<style>body{font-family:sans-serif;text-align:center;padding:48px 16px;background:#f5f2ff}
a{display:inline-block;margin-top:24px;padding:20px 32px;background:#7F52FF;color:#fff;border-radius:16px;text-decoration:none;font-size:22px}</style>
</head><body>
<h1>Hello Kotlin</h1>
<p>Built $(date '+%Y-%m-%d %H:%M')</p>
<a href="hello-kotlin.apk">Download &amp; install</a>
</body></html>
HTML

# Your computer's address on the local network
IP="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')"
URL="http://${IP:-<your-computer-ip>}:${PORT}/"

echo "On your phone (same Wi-Fi), open:  $URL"
echo "or scan this QR code with the camera:"
echo
exec docker run --rm -it --network host -v "$PWD/dist":/srv:ro -w /srv python:3-alpine sh -c "
  apk add -q --no-progress libqrencode-tools >/dev/null 2>&1 && qrencode -t ansiutf8 '$URL'
  echo 'Serving on port $PORT — press Ctrl+C to stop.'
  python3 -c \"import http.server as h; H = h.SimpleHTTPRequestHandler; H.extensions_map['.apk'] = 'application/vnd.android.package-archive'; h.test(H, h.ThreadingHTTPServer, port=$PORT, bind='0.0.0.0')\""
