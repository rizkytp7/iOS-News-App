#!/bin/zsh
# setup.sh — jalankan sekali setelah clone untuk generate .xcodeproj
set -e

SCRIPT_DIR="${0:a:h}"
cd "$SCRIPT_DIR"

echo "✅  Generating Xcode project..."
xcodegen generate --spec project.yml

echo ""
echo "✅  Done! Buka project dengan:"
echo "    open CodeNewsIOS.xcodeproj"
echo ""
echo "⚠️  Sebelum build, pastikan kamu mengisi API key di:"
echo "    Configs/Secrets.xcconfig"
echo "    Ganti YOUR_API_KEY dengan key dari https://newsapi.org"
