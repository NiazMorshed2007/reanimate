#!/usr/bin/env bash
# Installs the script dependencies once (bun) and checks that Chromium and ffmpeg are usable.
# Safe to re-run; it is a no-op when everything is already in place.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
if ! command -v bun >/dev/null; then echo "bun is required (https://bun.sh)"; exit 1; fi
FFMPEG=node_modules/ffmpeg-static/ffmpeg
[ -e "$FFMPEG.exe" ] || [ "${OS:-}" = "Windows_NT" ] && FFMPEG="$FFMPEG.exe"   # Windows (Git Bash)
if [ ! -d node_modules/playwright ] || [ ! -x "$FFMPEG" ]; then
  bun install --silent
fi
if ! bun -e 'const {chromium}=await import("playwright"); const b=await chromium.launch(); await b.close(); console.log("chromium ok")' 2>/dev/null; then
  echo "Chromium missing for this Playwright version, installing it..."
  bunx playwright install chromium
fi
"$FFMPEG" -hide_banner -version | head -1
echo "ready: $HERE"
