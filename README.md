# UndertaleModTool Linux Installer

**UndertaleModTool GUI** installer for Linux via Wine.

---

## Quick Start

Install or Update
```bash
curl -sL https://raw.githubusercontent.com/YarTom/UndertaleModTool-linux-installer/main/install-linux.sh | bash
```

Uninstall
```bash
curl -sL https://raw.githubusercontent.com/YarTom/UndertaleModTool-linux-installer/main/uninstall-linux.sh | bash
```

---

## Features

- Automatically installs wine
- Automatically creates wineprefix (`~/.wine_undertalemodtool`)
- You select the version (Stable or Nightly) for automatic installation
- Creates a desktop menu entry
- Creates 'utmt' and 'UndertaleModTool' for easy terminal access (optional)

---

## Requirements

- **curl**, **unzip**

---

## Usage

After installation:
- From applications menu → **UndertaleModTool**
- Or via terminal:
  ```bash
  ~/.wine_undertalemodtool/UndertaleModTool.sh [file]
  ```

---

## Tested On

- Linux Mint 22.2
- Fedora 43

---

### Reporting Issues

When creating a bug report, please include:
- Your Linux distribution
- Hardware configuration (CPU, GPU, RAM)
- Wine/Proton version
- Relevant log output

> **Create an issue:** [GitHub Issues](https://github.com/YarTom/UndertaleModTool-linux-installer/issues)
