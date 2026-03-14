#!/bin/bash

echo "==========================================="
echo "  UndertaleModTool Uninstaller for macOS"
echo "==========================================="
echo ""

PREFIX="$HOME/.wine_undertalemodtool"
LAUNCHER="$PREFIX/UndertaleModTool.sh"
APP_DIR="/Applications/UndertaleModTool.app"

if [ ! -f "$LAUNCHER" ]; then
    echo "No installation found at: $PREFIX"
    echo "Nothing to uninstall."
    exit 0
fi

echo "Found installation at: $PREFIX"
echo ""
echo "Will be removed:"
echo "  • Wine prefix: $PREFIX"
echo "  • Application: $APP_DIR"
echo "  • Terminal aliases (if added)"
echo ""
read -p "Do you want to continue? (y/N): " confirm < /dev/tty

if [ "$confirm" != "y" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "Removing files..."

rm -rf "$PREFIX"
echo "  ✓ Removed Wine prefix"

rm -rf "$APP_DIR"
echo "  ✓ Removed application bundle"

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u "$APP_DIR" 2>/dev/null || true

if [ -f ~/.zshrc ]; then
    sed -i '' '/# UndertaleModTool aliases/d' ~/.zshrc 2>/dev/null
    sed -i '' '/^alias UndertaleModTool=/d' ~/.zshrc 2>/dev/null
    sed -i '' '/^alias utmt=/d' ~/.zshrc 2>/dev/null
    echo "  ✓ Removed terminal aliases from ~/.zshrc"
fi

echo ""
echo "================================"
echo "      Uninstall completed!"
echo "================================"
echo ""
echo "UndertaleModTool has been removed."
