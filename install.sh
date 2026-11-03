#!/usr/bin/env bash
# install.sh: Automated installer for Horizon (Minecraft Rust Edition) without Microsoft Login
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}=== Horizon Offline Setup ===${NC}"
echo "Setting up Horizon (Minecraft Rust Edition) with local game resources..."

# 1. Directories setup
APPS_DIR="${HOME}/Applications"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
ICON_DIR="${HOME}/.local/share/icons/hicolor/512x512/apps"

mkdir -p "${APPS_DIR}" "${BIN_DIR}" "${DESKTOP_DIR}" "${ICON_DIR}"

# 2. Check / download horizon-launcher AppImage
LAUNCHER_APPIMAGE="${APPS_DIR}/horizon-launcher.AppImage"
if [ ! -f "${LAUNCHER_APPIMAGE}" ]; then
    echo -e "${YELLOW}Downloading Horizon Launcher AppImage...${NC}"
    # Query latest release asset from GitHub API
    DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/horizon-rust/horizon/releases | \
        jq -r '.[].assets[] | select(.name == "horizon-launcher-linux-x86_64.AppImage") | .browser_download_url' | head -n 1)

    if [ -z "${DOWNLOAD_URL}" ] || [ "${DOWNLOAD_URL}" = "null" ]; then
        DOWNLOAD_URL="https://github.com/horizon-rust/horizon/releases/download/launcher%400.2.37/horizon-launcher-linux-x86_64.AppImage"
    fi

    curl -fL -o "${LAUNCHER_APPIMAGE}" "${DOWNLOAD_URL}"
    chmod +x "${LAUNCHER_APPIMAGE}"
fi

# Link launcher into ~/.local/bin
ln -sfn "${LAUNCHER_APPIMAGE}" "${BIN_DIR}/horizon-launcher"

# Ensure at least one Horizon nightly/release is installed
if ! "${LAUNCHER_APPIMAGE}" versions | grep -q "installed"; then
    echo -e "${YELLOW}Installing latest Horizon release...${NC}"
    "${LAUNCHER_APPIMAGE}" install latest || true
fi

# 3. Detect Minecraft 26.3 game files
echo -e "${BLUE}Detecting local Minecraft installation...${NC}"
MC_PATH=""
CANDIDATES=(
    "${HOME}/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher"
    "${HOME}/.local/share/PrismLauncher"
    "${HOME}/.minecraft"
    "${HOME}/.local/share/modrinth-app"
    "${HOME}/.local/share/multimc"
)

for candidate in "${CANDIDATES[@]}"; do
    if [ -d "${candidate}" ]; then
        # Check if 26.3 is present or if it has assets
        if [ -d "${candidate}/instances/26.3" ] || [ -d "${candidate}/versions/26.3" ] || [ -d "${candidate}/assets" ]; then
            MC_PATH="${candidate}"
            echo -e "${GREEN}Found Minecraft files at:${NC} ${MC_PATH}"
            break
        fi
    fi
done

if [ -z "${MC_PATH}" ]; then
    echo -e "${YELLOW}Could not automatically detect Minecraft 26.3 install.${NC}"
    read -rp "Please enter the path to your Minecraft directory (e.g. PrismLauncher or .minecraft): " MC_PATH
fi

# 4. Prepare resources using horizon-prepare
echo -e "${YELLOW}Extracting and preparing game assets from ${MC_PATH}...${NC}"
"${LAUNCHER_APPIMAGE}" prepare --minecraft "${MC_PATH}"

# 5. Install play-horizon wrapper script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/scripts/play-horizon" "${BIN_DIR}/play-horizon"
chmod +x "${BIN_DIR}/play-horizon"

# 6. Extract icon and install desktop entry
TEMP_EXTRACT="$(mktemp -d /tmp/horizon-extract-XXXXXX)"
cd "${TEMP_EXTRACT}"
"${LAUNCHER_APPIMAGE}" --appimage-extract >/dev/null 2>&1 || true
if [ -f "squashfs-root/horizon.png" ]; then
    cp "squashfs-root/horizon.png" "${ICON_DIR}/horizon.png"
fi
cd /
rm -rf "${TEMP_EXTRACT}"

# Install desktop shortcut
cp "${SCRIPT_DIR}/desktop/horizon-offline.desktop" "${DESKTOP_DIR}/horizon.desktop"
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "${DESKTOP_DIR}" || true

echo -e "\n${BOLD}${GREEN}✔ Installation Complete!${NC}"
echo -e "You can now play Horizon without logging in:"
echo -e "  • Terminal:  ${BOLD}play-horizon${NC}"
echo -e "  • Desktop:   Launch ${BOLD}Horizon${NC} from your application menu."
