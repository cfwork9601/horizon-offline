# Horizon Offline / No-Login Setup

A simple setup and launcher utility for **[Horizon](https://playhorizon.dev)** (the open-source *Minecraft: Java Edition* rewrite implemented in Rust) that enables direct offline gameplay without requiring a Microsoft account login.

---

## Background

Horizon is a ground-up rewrite of Minecraft in Rust. While the engine itself is free and open-source, it cannot legally distribute proprietary textures, sounds, and block models. The official Horizon launcher normally enforces a Microsoft account login to verify game ownership before downloading those assets from Mojang.

However, Horizon's built-in `horizon-prepare` utility can extract and build these assets locally from an existing Minecraft installation (such as **Prism Launcher**, **MultiMC**, **Modrinth App**, or the standard launcher). Once the resources are compiled, the game binary (`horizon-client`) can run directly without authentication.

---

## Features

- **No Microsoft Account Login:** Skips the launcher's account sign-in gate.
- **Auto-Detection:** Automatically locates existing Minecraft 26.3 files across common launcher directories (e.g. Prism Launcher Flatpak / native).
- **Direct Launch Script:** Provides `play-horizon` to start single-player or offline multiplayer immediately.
- **Desktop Integration:** Installs a `.desktop` entry and app icon in GNOME / KDE application menus.

---

## Prerequisites

1. **Linux (x86_64)**
2. **Java 25 Runtime** (e.g. `sudo dnf install java-latest-openjdk` or `sudo apt install openjdk-25-jre`)
3. **Minecraft 26.3** installed in any launcher:
   - Prism Launcher (Flatpak or Native)
   - Official Minecraft Launcher (`~/.minecraft`)
   - Modrinth App / MultiMC

---

## Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/cfwork9601/horizon-offline.git
cd horizon-offline
```

### 2. Run the installer
```bash
./install.sh
```

The script will:
1. Download the official `horizon-launcher` AppImage to `~/Applications`.
2. Detect your local Minecraft 26.3 installation.
3. Extract and convert textures, block states, and sounds into Horizon's native format.
4. Install `play-horizon` into `~/.local/bin/` and configure the desktop shortcut.

---

## Usage

### Run from Terminal
```bash
play-horizon
```

You can pass standard `horizon-client` arguments:
```bash
# Launch directly into a specific world:
play-horizon --world "Survival"

# Launch in creative mode:
play-horizon --creative

# Set player username for offline multiplayer:
play-horizon --name "Player1"

# Connect to a local/offline server:
play-horizon --server "127.0.0.1:25565"

# Fullscreen mode:
play-horizon --fullscreen
```

### Run from Desktop
Search for **Horizon** in your application launcher / app grid and click to start.

---

## Project Structure

```text
horizon-offline/
├── install.sh                  # Automated setup script
├── scripts/
│   └── play-horizon            # Direct game client launcher
├── desktop/
│   └── horizon-offline.desktop # GNOME/KDE desktop launcher file
├── LICENSE                     # MIT License
└── README.md
```

---

## Disclaimer

This project is an independent setup script and is not affiliated with, endorsed by, or associated with Mojang Studios, Microsoft, or the Horizon project team. Minecraft is a trademark of Mojang and Microsoft.
