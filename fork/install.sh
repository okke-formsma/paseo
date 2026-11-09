#!/usr/bin/env bash
# Replace /Applications/Paseo.app with the latest fork build.
# Quitting Paseo stops the daemon and every running agent and terminal, including
# a Paseo terminal you run this from. So the script detaches and does the swap
# from a separate session. Log: ~/.paseo/fork-install.log
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"

if [[ "${1:-}" != "--now" ]]; then
  log="$HOME/.paseo/fork-install.log"
  perl -MPOSIX -e 'POSIX::setsid(); exec @ARGV' nohup "$0" --now >"$log" 2>&1 < /dev/null &
  echo "install: running detached; Paseo will quit and relaunch. Log: $log"
  exit 0
fi

arch=$(uname -m)
build="$root/packages/desktop/release/mac-arm64/Paseo.app"
[[ "$arch" == x86_64 ]] && build="$root/packages/desktop/release/mac/Paseo.app"
[[ -d "$build" ]] || { echo "install: no build at $build; run fork/build.sh" >&2; exit 1; }

sleep 2
echo "install: quitting Paseo"
osascript -e 'tell application "Paseo" to quit' || true
for _ in $(seq 1 60); do pgrep -x Paseo >/dev/null || break; sleep 1; done
pkill -x Paseo || true

# Stop a daemon left running after quit so the new bundle starts its own.
if [[ -x /Applications/Paseo.app/Contents/Resources/bin/paseo ]]; then
  /Applications/Paseo.app/Contents/Resources/bin/paseo daemon stop || true
fi

backup="$HOME/.paseo/fork-backup"
mkdir -p "$backup"
if [[ -d /Applications/Paseo.app ]]; then
  rm -rf "$backup/Paseo.app"
  mv /Applications/Paseo.app "$backup/Paseo.app"
  echo "install: previous app saved to $backup/Paseo.app"
fi
ditto "$build" /Applications/Paseo.app
xattr -dr com.apple.quarantine /Applications/Paseo.app 2>/dev/null || true
echo "install: installed $(cat "$(dirname "$build")/BUILT_FROM" 2>/dev/null || echo unknown)"
open /Applications/Paseo.app
