#!/bin/bash
#
# build-app.sh — builds SecureClone.app from the Swift package.
#
# Requirements: macOS 14+ with either Xcode or just the Command Line Tools
# (`xcode-select --install`). No Xcode project file needed.
#
# Usage:  ./build-app.sh            → build/SecureClone.app  (+ zip)
#         ./build-app.sh --universal → Intel + Apple Silicon binary
#

set -euo pipefail
cd "$(dirname "$0")"

ARCH_FLAGS=""
if [[ "${1:-}" == "--universal" ]]; then
    ARCH_FLAGS="--arch arm64 --arch x86_64"
fi

echo "▶ Building SecureClone (release)…"
# shellcheck disable=SC2086
swift build -c release $ARCH_FLAGS

BIN="$(swift build -c release $ARCH_FLAGS --show-bin-path)/SecureClone"
APP="build/SecureClone.app"

echo "▶ Assembling app bundle…"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/SecureClone"
cp Info.plist "$APP/Contents/Info.plist"
echo -n "APPL????" > "$APP/Contents/PkgInfo"

echo "▶ Ad-hoc signing…"
codesign --force --deep --sign - "$APP"

echo "▶ Zipping…"
rm -f build/SecureClone.zip
ditto -c -k --keepParent "$APP" build/SecureClone.zip

echo
echo "✅ Done:  $APP"
echo "         build/SecureClone.zip"
echo
echo "First launch: right-click SecureClone.app → Open (ad-hoc signed, not notarized)."
