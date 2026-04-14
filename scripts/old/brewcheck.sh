#!/usr/bin/env bash
# scripts/brew-check.sh

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DETECTED_HOST=$(scutil --get LocalHostName 2>/dev/null || hostname -s)
TARGET_HOST=${1:-${TARGET_HOST:-$DETECTED_HOST}}

echo -e "${BLUE}🔍 Analisando desvios do Homebrew para '${TARGET_HOST}'...${NC}"

# --- CASKS ---
echo -e "\n${BLUE}📦 [CASKS]${NC}"
NIX_CASKS=$(nix eval --json .#darwinConfigurations."$TARGET_HOST".config.homebrew.casks 2>/dev/null | jq -r '.[] | if type == "string" then . else .name end' | sort)
ACTUAL_CASKS=$(brew list --cask -1 2>/dev/null | sort)

echo -e "${GREEN}✅ SINCRONIZADOS:${NC}"
comm -12 <(echo "$NIX_CASKS") <(echo "$ACTUAL_CASKS") | sed 's/^/  - /'

echo -e "\n${YELLOW}➕ PARA INSTALAR (Nix -> Sistema):${NC}"
comm -23 <(echo "$NIX_CASKS") <(echo "$ACTUAL_CASKS") | sed 's/^/  - /'

echo -e "\n${RED}⚠️  SERÃO REMOVIDOS (Sistema -> Nix):${NC}"
comm -13 <(echo "$NIX_CASKS") <(echo "$ACTUAL_CASKS") | sed 's/^/  - /'

# --- BREWS (Formulae) ---
echo -e "\n${BLUE}🍺 [BREWS]${NC}"
NIX_BREWS=$(nix eval --json .#darwinConfigurations."$TARGET_HOST".config.homebrew.brews 2>/dev/null | jq -r '.[] | if type == "string" then . else .name end' | sort)
ACTUAL_BREWS=$(brew list --formula -1 2>/dev/null | sort)

echo -e "${GREEN}✅ SINCRONIZADOS:${NC}"
comm -12 <(echo "$NIX_BREWS") <(echo "$ACTUAL_BREWS") | sed 's/^/  - /'

echo -e "\n${YELLOW}➕ PARA INSTALAR (Nix -> Sistema):${NC}"
comm -23 <(echo "$NIX_BREWS") <(echo "$ACTUAL_BREWS") | sed 's/^/  - /'

echo -e "\n${RED}⚠️  SERÃO REMOVIDOS (Sistema -> Nix):${NC}"
comm -13 <(echo "$NIX_BREWS") <(echo "$ACTUAL_BREWS") | sed 's/^/  - /'

# --- TAPS ---
echo -e "\n${BLUE}🚰 [TAPS]${NC}"
NIX_TAPS=$(nix eval --json .#darwinConfigurations."$TARGET_HOST".config.homebrew.taps 2>/dev/null | jq -r '.[] | if type == "string" then . else .name end' | sort)
ACTUAL_TAPS=$(brew tap | sort)

echo -e "${GREEN}✅ SINCRONIZADOS:${NC}"
comm -12 <(echo "$NIX_TAPS") <(echo "$ACTUAL_TAPS") | sed 's/^/  - /'

echo -e "\n${YELLOW}➕ PARA ADICIONAR (Nix -> Sistema):${NC}"
comm -23 <(echo "$NIX_TAPS") <(echo "$ACTUAL_TAPS") | sed 's/^/  - /'

echo -e "\n${RED}⚠️  SERÃO REMOVIDOS (Sistema -> Nix):${NC}"
comm -13 <(echo "$NIX_TAPS") <(echo "$ACTUAL_TAPS") | sed 's/^/  - /'

echo -e "\n${BLUE}-------------------------------------------${NC}"