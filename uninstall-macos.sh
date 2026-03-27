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
APP_DIR="/Applications/UndertaleModTool.app"

if [ ! -f "$LAUNCHER" ]; then
    echo -e "${RED}No installation found at: $PREFIX${NC}"
    echo -e "${YELLOW}Nothing to uninstall.${NC}"
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
read confirm < /dev/tty

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo -e "${GREEN}Uninstall cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${RED}Removing files...${NC}"

rm -rf "$PREFIX"
echo -e "  ${RED}✓ Removed Wine prefix"

rm -rf "$APP_DIR"
echo -e "  ${RED}✓ Removed desktop entry"

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u "$APP_DIR" 2>/dev/null || true

if [ -f ~/.zshrc ]; then
    sed -i '' '/# UndertaleModTool aliases/d' ~/.zshrc 2>/dev/null
    sed -i '' '/^alias UndertaleModTool=/d' ~/.zshrc 2>/dev/null
    sed -i '' '/^alias utmt=/d' ~/.zshrc 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Removed terminal aliases from ~/.zshrc"
fi

echo ""
echo -e "${RED}================================${NC}"
echo -e "${RED}${BOLD}      Uninstall completed!${NC}"
echo -e "${RED}================================${NC}"
echo ""
echo -e "${GREEN}UndertaleModTool has been removed.${NC}"