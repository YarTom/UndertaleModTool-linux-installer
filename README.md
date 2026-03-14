# UndertaleModTool Unix Installer

Unofficial **[UndertaleModTool GUI](https://github.com/UnderminersTeam/UndertaleModTool)** installer for Linux and macOS via Wine.

---

## Install or Update

Just one command:

### Linux

```bash
curl -sL https://raw.githubusercontent.com/YarTom/UndertaleModTool-linux-installer/main/install-linux.sh | bash
```

### MacOS
```bash
curl -sL https://raw.githubusercontent.com/YarTom/UndertaleModTool-linux-installer/main/install-macos.sh | zsh
```

![macos](https://raw.githubusercontent.com/YarTom/UndertaleModTool-linux-installer/main/images/macOS.png)

---

### Usage

After installation:
- From applications menu → **UndertaleModTool**
- Or via terminal:
  ```bash
  ~/.wine_undertalemodtool/UndertaleModTool.sh [path_to_file]
  ```
- If you chose to create aliases:
  ```bash
  UndertaleModTool [path_to_file]
  ```
  or simply:
  ```bash
  utmt [path_to_file]
  ```
---

### Uninstall

### Linux

```bash
curl -sL https://raw.githubusercontent.com/YarTom/UndertaleModTool-linux-installer/main/uninstall-linux.sh | bash
```

### MacOS

```bash
curl -sL https://raw.githubusercontent.com/YarTom/UndertaleModTool-linux-installer/main/uninstall-macos.sh | zsh
```

---

## About

I have been using UndertaleModTool via wine on Linux for a long time and encountered the same issues many times.

The goal of this project is to create a unified way to install UndertaleModTool GUI for Linux, solving common issues until UTMT migrates to a framework with native Linux support.

---

## Features
- Automatically changes DPI in a separate Wine prefix for UTMT (scales up the UI)
- Automatically installs Wine (if necessary)
- You select the version (Stable or Nightly) for automatic installation
- Creates a desktop menu entry
- Creates 'utmt' and 'UndertaleModTool' aliases for easy terminal access (optional)

---

## Requirements

- **curl**, **unzip**

---

## Tested On

- Linux Mint 22.2
- Fedora 43

- MacOS Big Sur 11.7.11

_You can open a pull request and add your distribution here if the script works for you._

---

## Fixed Issues

### Graphical Artifacts

Issues with context menu rendering and other graphical artifacts.
![Artifacts](https://raw.githubusercontent.com/YarTom/UndertaleModTool-linux-installer/main/images/artifacts.jpg)

Fixed by automatically adding:
```
WINEDLLOVERRIDES="d3d9=d;d3d10=d;d3d11=d
```
to launch parameters. This disables hardware acceleration for graphics, which removes the artifacts.

### Crash When Trying to Open Code

Fixed by automatically installing required fonts into the Wine prefix:
```bash
winetricks corefonts
```

### Issues with Save File Paths

Fixed by adding special path handling in the launch script. For details, refer to the launch script: `~/.wine_undertalemodtool/UndertaleModTool.sh`

---

## Reporting Issues

When creating a bug report, please include:
- Your Linux distribution
- Hardware configuration (CPU, GPU, RAM)
- Wine/Proton version
- Relevant log output

> **Create an issue:** [GitHub Issues](https://github.com/YarTom/UndertaleModTool-linux-installer/issues)
