#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}${BOLD}  UndertaleModTool Installer for Linux${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

PREFIX="$HOME/.wine_undertalemodtool"
LAUNCHER="$PREFIX/UndertaleModTool.sh"

if [ -f "$LAUNCHER" ]; then
    echo -e "An existing installation was found at: ${BLUE}$PREFIX${NC}"
    echo -e "Do you want to reinstall? This will overwrite the current version. (${RED}y${NC}/${GREEN}N${NC}): \c"
    read reinstall < /dev/tty
    if [ "$reinstall" != "y" ] && [ "$reinstall" != "Y" ]; then
        echo -e "${GREEN}Installation cancelled.${NC}"
        exit 0
    fi
    echo -e "${GREEN}Proceeding with reinstallation...${NC}"
    echo ""
fi

echo -e "${GREEN}Fetching release information from GitHub...${NC}"
RELEASE_INFO=$(curl -s https://api.github.com/repos/UnderminersTeam/UndertaleModTool/releases/latest)
NIGHTLY_INFO=$(curl -s https://api.github.com/repos/UnderminersTeam/UndertaleModTool/releases/tags/nightly)

RELEASE_URL=$(echo "$RELEASE_INFO" | grep -o "https://github.com/.*-Windows.zip" | head -1)
NIGHTLY_URL=$(echo "$NIGHTLY_INFO" | grep -o "https://github.com/.*GUI-windows-latest-Debug-isBundled-true-isSingleFile-false.zip" | head -1)

echo -e "${GREEN}Checking for Wine installation...${NC}"
command -v wine &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "Wine is not installed."
    echo -e "Do you want to install Wine now? (${RED}y${NC}/${GREEN}N${NC}): \c"
    read choice < /dev/tty
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        echo -e "${GREEN}Installing Wine and winetricks...${NC}"
        if command -v apt &> /dev/null; then
            sudo apt install -y wine winetricks
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wine winetricks
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wine winetricks
        else
            echo -e "${RED}Error: Unsupported package manager. Please install Wine manually, then run this script again.${NC}"
            exit 1
        fi
        echo -e "${GREEN}Wine installation completed.${NC}"
    else
        echo -e "${RED}Wine is required to run UndertaleModTool. Installation cancelled.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Wine is already installed.${NC}"
fi
echo ""

echo -e "${GREEN}${BOLD}Available versions:${NC}"
echo -e "  ${BLUE}1)${NC} Release (Stable)"
echo -e "  ${BLUE}2)${NC} Nightly (Latest)"
echo ""
echo -e "Choose version (${BLUE}1${NC} or ${BLUE}2${NC}): \c"
read choice < /dev/tty

if [ "$choice" = "1" ]; then
    URL="$RELEASE_URL"
    VERSION_NAME="Release (Stable)"
    echo -e "Selected: ${BLUE}$VERSION_NAME${NC}"
elif [ "$choice" = "2" ]; then
    URL="$NIGHTLY_URL"
    VERSION_NAME="Nightly (Latest)"
    echo -e "Selected: ${BLUE}$VERSION_NAME${NC}"
else
    echo -e "${RED}Invalid choice. Canceling installation.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Setting up Wine prefix at: ${BLUE}$PREFIX${NC}"
mkdir -p "$PREFIX"

echo -e "${GREEN}Installing core fonts (this may take a moment)...${NC}"
WINEPREFIX="$PREFIX" winetricks -q corefonts

echo -e "${GREEN}Configuring DPI...${NC}"
WINEPREFIX="$PREFIX" wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d 144 /f

echo ""
echo -e "${GREEN}Downloading UndertaleModTool...${NC}"
curl -# -L "$URL" -o "/tmp/UndertaleModTool.zip"

echo -e "${GREEN}Extracting files...${NC}"
mkdir -p "$PREFIX/drive_c/Program Files/UndertaleModTool"
unzip -o "/tmp/UndertaleModTool.zip" -d "$PREFIX/drive_c/Program Files/UndertaleModTool" >/dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to extract the archive.${NC}"
    rm "/tmp/UndertaleModTool.zip"
    exit 1
fi
rm "/tmp/UndertaleModTool.zip"

echo -e "${GREEN}Downloading UTMT icon...${NC}"
curl -s "https://raw.githubusercontent.com/UnderminersTeam/UndertaleModTool/refs/heads/master/UndertaleModTool/icon.ico" -o "$PREFIX/drive_c/Program Files/UndertaleModTool/icon.ico"

echo -e "${GREEN}Creating launch script...${NC}"
cat > "$PREFIX/UndertaleModTool.sh" << EOF
#!/bin/bash

# Hi! This is a simple script to run Undertale Mod Tool using Wine on Linux.

# Wine path is needed to convert the path to the data.win file into a format
# that Windows understands.
# Opening the file will work without conversion, but then when saving,
# you will need to manually specify the path to data.win in Windows format.
_WINE_PATH=\$(echo "\$1" | sed 's#^file://##' | sed 's#/#\\#g' | sed 's#^#Z:\\\\#')
# Uncomment if you want to use native path:
# _WINE_PATH="\$1"

# UTMT path
_UTMT_PATH="$PREFIX/drive_c/Program Files/UndertaleModTool/UndertaleModTool.exe"

# Your Wineprefix path. You can configure it by using the command:
# 'WINEPREFIX="$PREFIX" winecfg'
_WINEPREFIX="$PREFIX"

# Disable hardware acceleration because it causes artifacts.
# You can remove this line if you have a compatible graphics driver.
_WINEDLLOVERRIDES="d3d9=d;d3d10=d;d3d11=d"

# Display server. I recommend using Xorg,
# since there may be display issues with Wayland.
# If you have Wayland, the program will run through XWayland.
# Use xorg or XWayland:
_DISPLAY=:0
# Uncomment next line to force use of Wayland (only for wine versions 10+):
# _DISPLAY=

# Launch command
DISPLAY=\$_DISPLAY WINEDLLOVERRIDES="\$_WINEDLLOVERRIDES" WINEPREFIX="\$_WINEPREFIX" wine "\$_UTMT_PATH" "\$_WINE_PATH"
EOF
chmod +x "$PREFIX/UndertaleModTool.sh"

echo -e "${GREEN}Creating desktop entry...${NC}"
mkdir -p "$HOME/.local/share/applications/"
cat > "$HOME/.local/share/applications/UndertaleModTool.desktop" << EOF
[Desktop Entry]
Name=UndertaleModTool
Exec=env $PREFIX/UndertaleModTool.sh %f
Icon=$PREFIX/drive_c/Program Files/UndertaleModTool/icon.ico
Type=Application
Categories=Development;
MimeType=application/octet-stream;
Keywords=utmt;
EOF
chmod +x "$HOME/.local/share/applications/UndertaleModTool.desktop"
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

echo -e "Do you want to add UndertaleModTool aliases for easy terminal access? (${RED}y${NC}/${GREEN}N${NC}): \c"
read add_alias < /dev/tty

for file in ~/.profile ~/.bashrc ~/.zshrc ~/.config/fish/config.fish; do
    [ -f "$file" ] && sed -i '/^alias UndertaleModTool=/d' "$file" 2>/dev/null
    [ -f "$file" ] && sed -i '/^alias utmt=/d' "$file" 2>/dev/null
done

if [ "$add_alias" = "y" ] || [ "$add_alias" = "Y" ]; then
    alias_cmd="alias UndertaleModTool=\"$PREFIX/UndertaleModTool.sh\"
alias utmt=\"$PREFIX/UndertaleModTool.sh\""

    for file in ~/.profile ~/.bashrc ~/.zshrc ~/.config/fish/config.fish; do
        if [ -f "$file" ]; then
            echo -e "${GREEN}Added aliases 'UndertaleModTool' and 'utmt' to $file${NC}"
        fi
    done
    echo -e "${YELLOW}Restart your terminal to apply the changes.${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}${BOLD}  Installation completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}You can now launch UndertaleModTool:${NC}"
echo -e "  • From your applications menu (search for 'UndertaleModTool')"
if [ "$add_alias" = "y" ] || [ "$add_alias" = "Y" ]; then
    echo -e "  • Or via terminal: '${BLUE}UndertaleModTool [file]${NC}' or '${BLUE}utmt [file]${NC}'"
else
    echo -e "  • Or via terminal: ${BLUE}$PREFIX/UndertaleModTool.sh [file]${NC}"
fi
echo ""
echo -e "${GREEN}${BOLD}Notes:${NC}"
echo -e "  • First launch may take longer as Wine initializes"
echo -e "  • To reinstall or update, simply run this script again"
echo -e "  • For more configuration options, edit the launch script at: ${BLUE}$LAUNCHER${NC}"
echo -e "  • If you see any issues, please report them to me (https://github.com/YarTom/UndertaleModTool-linux-installer/issues)"
echo ""
echo -e "${GREEN}Enjoy modding!${NC}"
