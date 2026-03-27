#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}${BOLD}  UndertaleModTool Uninstaller for Linux${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

PREFIX="$HOME/.wine_undertalemodtool"
LAUNCHER="$PREFIX/UndertaleModTool.sh"
DESKTOP_FILE="$HOME/.local/share/applications/UndertaleModTool.desktop"

if [ ! -f "$LAUNCHER" ]; then
    echo -e "${RED}No installation found at: ${BLUE}$PREFIX${NC}"
    echo -e "${RED}Nothing to uninstall.${NC}"
    exit 0
fi

echo -e "Found installation at: ${NC}$PREFIX${NC}"
echo ""
echo -e "${GREEN}${BOLD}Will be removed:${NC}"
echo -e "  • Wine prefix: ${BLUE}$PREFIX${NC}"
echo -e "  • Desktop entry: ${BLUE}$DESKTOP_FILE${NC}"
echo -e "  • Terminal aliases (if added)"
echo ""

echo -e "Do you want to continue? (${RED}y${NC}/${GREEN}N${NC}): \c"
read -p "" confirm < /dev/tty

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo -e "${GREEN}Uninstall cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${RED}Removing files...${NC}"

rm -rf "$PREFIX"
echo -e "  ${RED}✓ Removed Wine prefix"

rm -f "$DESKTOP_FILE"
echo -e "  ${RED}✓ Removed desktop entry"

for file in ~/.profile ~/.bashrc ~/.zshrc ~/.config/fish/config.fish; do
    [ -f "$file" ] && sed -i '/^alias UndertaleModTool/d' "$file" 2>/dev/null
    [ -f "$file" ] && sed -i '/^alias utmt/d' "$file" 2>/dev/null
done
echo -e "  ${RED}✓ Removed terminal aliases"

update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

echo ""
echo -e "${RED}================================${NC}"
echo -e "${RED}${BOLD}      Uninstall completed!${NC}"
echo -e "${RED}================================${NC}"
echo ""
echo -e "${GREEN}UndertaleModTool has been removed.${NC}"
