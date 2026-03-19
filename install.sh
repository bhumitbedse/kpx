#!/usr/bin/env bash
# kpx installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/bhumitbedse/kpx/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/bhumitbedse/kpx/main/install.sh | sudo bash

set -euo pipefail

REPO="bhumitbedse/kpx"
BINARY="kpx"
RAW_URL="https://raw.githubusercontent.com/${REPO}/main/${BINARY}"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[38;5;87m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✔  $*${NC}"; }
info() { echo -e "${CYAN}ℹ  $*${NC}"; }
warn() { echo -e "${YELLOW}⚠  $*${NC}"; }
die()  { echo -e "${RED}✗  $*${NC}" >&2; exit 1; }

# ── Determine install prefix ──────────────────────────────────────────────────
if [ "$(id -u)" -eq 0 ]; then
    PREFIX="/usr/local/bin"
else
    PREFIX="${HOME}/.local/bin"
fi

# Allow override via environment
PREFIX="${INSTALL_PREFIX:-$PREFIX}"

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}kpx installer${NC}"
echo "────────────────────────────────────"
info "Install location : ${PREFIX}/${BINARY}"
echo ""

# ── Check dependencies ────────────────────────────────────────────────────────
info "Checking dependencies..."

MISSING=()
command -v keepassxc-cli &>/dev/null || MISSING+=("keepassxc-cli")
command -v fzf           &>/dev/null || MISSING+=("fzf")

if [ ${#MISSING[@]} -gt 0 ]; then
    warn "Missing dependencies: ${MISSING[*]}"
    echo ""
    echo "Install with:"
    if command -v apt &>/dev/null; then
        echo "  sudo apt install keepassxc fzf xclip"
    elif command -v pacman &>/dev/null; then
        echo "  sudo pacman -S keepassxc fzf xclip"
    elif command -v dnf &>/dev/null; then
        echo "  sudo dnf install keepassxc fzf xclip"
    elif command -v brew &>/dev/null; then
        echo "  brew install keepassxc fzf"
    fi
    echo ""
    warn "Continuing install anyway..."
fi

# Check clipboard
if ! command -v xclip &>/dev/null && ! command -v wl-copy &>/dev/null \
   && ! command -v pbcopy &>/dev/null && ! command -v clip.exe &>/dev/null; then
    warn "No clipboard tool found. Install xclip, wl-clipboard, or pbcopy."
fi

# ── Download ──────────────────────────────────────────────────────────────────
echo ""
info "Downloading ${BINARY}..."

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

if command -v curl &>/dev/null; then
    curl -fsSL "$RAW_URL" -o "$TMP" || die "Download failed. Check your internet connection."
elif command -v wget &>/dev/null; then
    wget -qO "$TMP" "$RAW_URL" || die "Download failed. Check your internet connection."
else
    die "Neither curl nor wget found. Please install one."
fi

# Verify it looks like our script
if ! grep -q "kpx" "$TMP"; then
    die "Downloaded file doesn't look right. Please check the URL."
fi

ok "Download complete"

# ── Install ───────────────────────────────────────────────────────────────────
echo ""
info "Installing to ${PREFIX}/${BINARY}..."

mkdir -p "$PREFIX"
install -m 755 "$TMP" "${PREFIX}/${BINARY}"

ok "Installed ${PREFIX}/${BINARY}"

# ── PATH check ────────────────────────────────────────────────────────────────
echo ""
if ! echo "$PATH" | grep -q "$PREFIX"; then
    warn "${PREFIX} is not in your PATH."
    echo ""
    echo "  Add this to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo -e "  ${YELLOW}export PATH=\"${PREFIX}:\$PATH\"${NC}"
    echo ""
    echo "  Then reload: source ~/.bashrc"
fi

# ── Init config ───────────────────────────────────────────────────────────────
CONFIG_DIR="${HOME}/.config/kpx"
if [ ! -f "${CONFIG_DIR}/config" ]; then
    echo ""
    info "Creating default config..."
    "${PREFIX}/${BINARY}" --init 2>/dev/null || true
    ok "Config created at ${CONFIG_DIR}/config"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────"
ok "kpx installed successfully!"
echo ""
echo "  Next steps:"
echo "  1. Edit your config:  nano ~/.config/kpx/config"
echo "  2. Add your database: database = /path/to/passwords.kdbx"
echo "  3. Run:               kpx"
echo ""
