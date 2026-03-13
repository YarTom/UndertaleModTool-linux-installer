#!/bin/bash

echo "========================================"
echo "  UndertaleModTool Installer for Linux"
echo "========================================"
echo ""

PREFIX="$HOME/.wine_undertalemodtool"
LAUNCHER="$PREFIX/UndertaleModTool.sh"

if [ -f "$LAUNCHER" ]; then
    echo "An existing installation was found at: $PREFIX"
    read -p "Do you want to reinstall? This will overwrite the current version. (y/N): " reinstall < /dev/tty
    if [ "$reinstall" != "y" ]; then
        echo "Installation cancelled."
        exit 0
    fi
    echo "Proceeding with reinstallation..."
    echo ""
fi

echo "Fetching release information from GitHub..."
RELEASE_INFO=$(curl -s https://api.github.com/repos/UnderminersTeam/UndertaleModTool/releases/latest)
NIGHTLY_INFO=$(curl -s https://api.github.com/repos/UnderminersTeam/UndertaleModTool/releases/tags/nightly)

RELEASE_URL=$(echo "$RELEASE_INFO" | grep -o "https://github.com/.*-Windows.zip" | head -1)
NIGHTLY_URL=$(echo "$NIGHTLY_INFO" | grep -o "https://github.com/.*GUI-windows-latest-Debug-isBundled-true-isSingleFile-false.zip" | head -1)

echo "Checking for Wine installation..."
command -v wine &> /dev/null
if [ $? -ne 0 ]; then
    echo "Wine is not installed. Do you want to install Wine now? (requires sudo password)"
    read -p "> " install_wine < /dev/tty
    if [ "$install_wine" = "y" ]; then
        echo "Installing Wine and winetricks..."
        if command -v apt &> /dev/null; then
            sudo apt install -y wine winetricks
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wine winetricks
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wine winetricks
        else
            echo "Error: Unsupported package manager. Please install Wine manually, then run this script again."
            exit 1
        fi
        echo "Wine installation completed."
    else
        echo "Wine is required to run UndertaleModTool. Installation cancelled."
        exit 1
    fi
else
    echo "Wine is already installed."
fi
echo ""

echo "Available versions:"
echo "  1) Release (Stable)"
echo "  2) Nightly (Latest)"
echo ""
read -p "Choose version (1 or 2): " choice < /dev/tty

if [ "$choice" = "1" ]; then
    URL="$RELEASE_URL"
    VERSION_NAME="Release (Stable)"
    echo "Selected: $VERSION_NAME"
elif [ "$choice" = "2" ]; then
    URL="$NIGHTLY_URL"
    VERSION_NAME="Nightly (Latest)"
    echo "Selected: $VERSION_NAME"
else
    echo "Invalid choice. Canceling installation."
    exit 1
fi

echo ""
echo "Setting up Wine prefix at: $PREFIX"
mkdir -p "$PREFIX"

echo "Installing core fonts (this may take a moment)..."
winetricks -q corefonts 2>/dev/null

echo ""
echo "Downloading UndertaleModTool..."
curl -# -L "$URL" -o "/tmp/UndertaleModTool.zip"

echo "Extracting files..."
mkdir -p "$PREFIX/drive_c/Program Files/UndertaleModTool"
unzip -o "/tmp/UndertaleModTool.zip" -d "$PREFIX/drive_c/Program Files/UndertaleModTool" >/dev/null
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract the archive."
    rm "/tmp/UndertaleModTool.zip"
    exit 1
fi
rm "/tmp/UndertaleModTool.zip"

echo "Downloading UTMT icon..."
curl -s "https://raw.githubusercontent.com/UnderminersTeam/UndertaleModTool/refs/heads/master/UndertaleModTool/icon.ico" -o "$PREFIX/drive_c/Program Files/UndertaleModTool/icon.ico" 2>/dev/null

echo "Creating launch script..."
cat > "$PREFIX/UndertaleModTool.sh" << EOF
#!/bin/bash
WINE_PATH="Z:\${1//\//\\\\}"
WINEPREFIX="$PREFIX" \\
WINEDLLOVERRIDES="d3d9=d;d3d10=d;d3d11=d" \\
wine "$PREFIX/drive_c/Program Files/UndertaleModTool/UndertaleModTool.exe" "\$WINE_PATH"
EOF
chmod +x "$PREFIX/UndertaleModTool.sh"

echo "Creating desktop entry..."
mkdir -p "$HOME/.local/share/applications/"
cat > "$HOME/.local/share/applications/UndertaleModTool.desktop" << EOF
[Desktop Entry]
Name=UndertaleModTool
Exec=env $PREFIX/UndertaleModTool.sh %f
Icon=$PREFIX/drive_c/Program Files/UndertaleModTool/icon.ico
Type=Application
Categories=Development;
MimeType=application/octet-stream;
EOF
chmod +x "$HOME/.local/share/applications/UndertaleModTool.desktop"
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

echo "Configuring dpi..."
WINEPREFIX="$PREFIX" wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d 144 /f 2>/dev/null

echo ""
echo "========================================"
echo "  Installation completed successfully!"
echo "========================================"
echo ""
echo "You can now launch UndertaleModTool:"
echo "  • From your applications menu (search for 'UndertaleModTool')"
echo "  • Or via terminal: $PREFIX/UndertaleModTool.sh [file]"
echo ""
echo "Notes:"
echo "  • First launch may take longer as Wine initializes"
echo "  • To reinstall or update, simply run this script again"
echo "  • To configure the wine settings run 'WINEPREFIX=\"$PREFIX\" winecfg'"
echo "  • If you see any issues, please report them to me (https://github.com/YarTom/UndertaleModTool-linux-installer/issues)"
echo ""
echo "Enjoy modding!"