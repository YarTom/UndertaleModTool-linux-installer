#!/bin/bash

echo "================================"
echo "  UndertaleModTool Uninstaller"
echo "================================"
echo ""

PREFIX="$HOME/.wine_undertalemodtool"
LAUNCHER="$PREFIX/UndertaleModTool.sh"
DESKTOP_FILE="$HOME/.local/share/applications/UndertaleModTool.desktop"

if [ ! -f "$LAUNCHER" ]; then
    echo "No installation found at: $PREFIX"
    echo "Nothing to uninstall."
    exit 0
fi

echo "Found installation at: $PREFIX"
echo ""
echo "Will be removed:"
echo "  • Wine prefix: $PREFIX"
echo "  • Desktop entry: $DESKTOP_FILE"
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

rm -f "$DESKTOP_FILE"
echo "  ✓ Removed desktop entry"

update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

echo ""
echo "================================"
echo "  Uninstall completed!"
echo "================================"
echo ""
echo "UndertaleModTool has been removed."