#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}${BOLD}  UndertaleModTool Installer for macOS${NC}"
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
    echo -e "Do you want to install Wine via Homebrew? (${RED}y${NC}/${GREEN}N${NC}): \c"
    read install_wine < /dev/tty
    if [ "$install_wine" = "y" ] || [ "$install_wine" = "Y" ]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}Homebrew is not installed. Please install Homebrew first:${NC}"
            echo -e "  ${WHITE}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
            exit 1
        fi
        echo "Installing Wine..."
        brew install --cask wine-stable
        echo "Wine installation completed."
    else
        echo -e "${RED}Wine is required to run UndertaleModTool. Installation cancelled.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Wine is already installed.${NC}"
fi
if brew list --formula | grep -q "^winetricks$"; then
    # do flipping nothing :P could maybe print WineTricks is installed
else
    echo "WineTricks is not installed."
    printf "Do you want to install WineTricks via Homebrew? (requires sudo password) (y/N): "
    
    read install_winetricks < /dev/tty
    if [ "$install_winetricks" = "y" ] || [ "$install_winetricks" = "Y" ]; then
        if ! command -v brew &> /dev/null; then
            echo "Homebrew is not installed. Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        echo "Installing winetricks..."
        brew install winetricks
        echo "WineTricks installation completed."
    else
        echo "WineTricks is required to run UndertaleModTool. Installation cancelled."
        exit 1
    fi
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
unzip -o "/tmp/UndertaleModTool.zip" -d "$PREFIX/drive_c/Program Files/UndertaleModTool"
rm "/tmp/UndertaleModTool.zip"

echo -e "${GREEN}Downloading UTMT icon...${NC}"
curl -s "https://raw.githubusercontent.com/UnderminersTeam/UndertaleModTool/refs/heads/master/UndertaleModTool/icon.ico" -o "/tmp/utmt_icon.ico"

if [ -f "/tmp/utmt_icon.ico" ]; then
    sips -s format png "/tmp/utmt_icon.ico" --out "/tmp/utmt_icon.png"
fi

echo -e "${GREEN}Creating launch script...${NC}"
cat > "$PREFIX/UndertaleModTool.sh" << EOF
#!/bin/bash

# Hi! This is a simple script to run Undertale Mod Tool using Wine on macOS.

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

# Launch command
WINEDLLOVERRIDES="\$_WINEDLLOVERRIDES" WINEPREFIX="\$_WINEPREFIX" /usr/local/bin/wine "\$_UTMT_PATH" "\$_WINE_PATH"
EOF
chmod +x "$PREFIX/UndertaleModTool.sh"

echo -e "${GREEN}Creating application bundle...${NC}"
APP_DIR="/Applications/UndertaleModTool.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

if [ -f "/tmp/utmt_icon.png" ]; then
    mkdir -p /tmp/utmt_icon.iconset
    sips -z 512 512 /tmp/utmt_icon.png --out /tmp/utmt_icon.iconset/icon_512x512.png 2>/dev/null
    sips -z 256 256 /tmp/utmt_icon.png --out /tmp/utmt_icon.iconset/icon_256x256.png 2>/dev/null
    sips -z 128 128 /tmp/utmt_icon.png --out /tmp/utmt_icon.iconset/icon_128x128.png 2>/dev/null
    cp /tmp/utmt_icon.png /tmp/utmt_icon.iconset/icon_512x512@2x.png 2>/dev/null
    cp /tmp/utmt_icon.iconset/icon_256x256.png /tmp/utmt_icon.iconset/icon_512x512@2x.png 2>/dev/null
    cp /tmp/utmt_icon.iconset/icon_128x128.png /tmp/utmt_icon.iconset/icon_256x256@2x.png 2>/dev/null
    iconutil -c icns /tmp/utmt_icon.iconset -o "$APP_DIR/Contents/Resources/icon.icns" 2>/dev/null
    rm -rf /tmp/utmt_icon.iconset
fi
rm -f "/tmp/utmt_icon.png" "/tmp/utmt_icon.ico"

cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>UndertaleModTool</string>
    <key>CFBundleIdentifier</key>
    <string>com.undertalemodtool.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>UndertaleModTool</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>All Files</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSHandlerRank</key>
            <string>Default</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.data</string>
                <string>public.content</string>
                <string>public.item</string>
                <string>public.database</string>
            </array>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>*</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

cat > "$APP_DIR/Contents/MacOS/UndertaleModTool" << EOF
#!/usr/bin/env bash
exec $PREFIX/UndertaleModTool.sh "$@"
EOF

chmod +x "$APP_DIR/Contents/MacOS/UndertaleModTool"
chmod -R 755 "$APP_DIR"
touch "$APP_DIR"

echo -e "${GREEN}Refreshing LaunchServices database...${NC}"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_DIR" 2>/dev/null || true

echo -e "Do you want to add UndertaleModTool aliases for easy terminal access? (${RED}y${NC}/${GREEN}N${NC}): \c"
read add_alias < /dev/tty

if [ -f ~/.zshrc ]; then
    sed -i '' '/# UndertaleModTool aliases/d' ~/.zshrc 2>/dev/null
    sed -i '' '/^alias UndertaleModTool=/d' ~/.zshrc 2>/dev/null
    sed -i '' '/^alias utmt=/d' ~/.zshrc 2>/dev/null
fi

if [ "$add_alias" = "y" ] || [ "$add_alias" = "Y" ]; then
    alias_cmd="
# UndertaleModTool aliases
alias UndertaleModTool=\"$PREFIX/UndertaleModTool.sh\"
alias utmt=\"$PREFIX/UndertaleModTool.sh\"
"
    if [ ! -f ~/.zshrc ]; then
        touch ~/.zshrc
        echo -e "${GREEN}Created ~/.zshrc${NC}"
    fi

    echo "$alias_cmd" >> ~/.zshrc
    echo -e "${GREEN}Added aliases 'UndertaleModTool' and 'utmt' to ~/.zshrc${NC}"
    echo -e "${YELLOW}Restart your terminal to apply the changes.${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}${BOLD}  Installation completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}You can now launch UndertaleModTool:${NC}"
echo -e "  • From Applications folder (search for 'UndertaleModTool')"
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
