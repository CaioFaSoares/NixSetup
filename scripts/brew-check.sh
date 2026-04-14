#!/usr/bin/env bash
# scripts/brew-check.sh

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Detecção do Hostname alvo
if [ -f "identity.nix" ]; then
    MACHINE_ID=$(grep "machineId =" identity.nix | cut -d'"' -f2)
    LOCAL_TARGET="mac-residencia-$MACHINE_ID"
else
    LOCAL_TARGET=$(scutil --get LocalHostName 2>/dev/null || hostname -s)
fi

TARGET_HOST=${1:-$LOCAL_TARGET}

echo -e "${BLUE}🔍 Analisando desvios do Homebrew para '${TARGET_HOST}'...${NC}"

# Função para extrair lista do Nix (usando --impure para ler identity.nix)
get_nix_list() {
    local attr=$1
    nix eval --impure --json .#darwinConfigurations."$TARGET_HOST".config.homebrew."$attr" 2>/dev/null | jq -r '.[] | if type == "string" then . else .name end' | sort
}

# --- CASKS ---
echo -e "\n${BLUE}📦 [CASKS]${NC}"
NIX_CASKS=$(get_nix_list "casks")
ACTUAL_CASKS=$(brew list --cask -1 2>/dev/null | sort)

echo -e "${GREEN}✅ SINCRONIZADOS:${NC}"
comm -12 <(echo "$NIX_CASKS") <(echo "$ACTUAL_CASKS") | sed 's/^/  - /'

echo -e "\n${YELLOW}➕ PARA INSTALAR (Nix -> Sistema):${NC}"
comm -23 <(echo "$NIX_CASKS") <(echo "$ACTUAL_CASKS") | sed 's/^/  - /'

echo -e "\n${RED}⚠️  EXTRAS NO SISTEMA (Serão removidos se o cleanup estiver ativo):${NC}"
comm -13 <(echo "$NIX_CASKS") <(echo "$ACTUAL_CASKS") | sed 's/^/  - /'

# --- BREWS (Formulae) ---
echo -e "\n${BLUE}🍺 [BREWS]${NC}"
NIX_BREWS=$(get_nix_list "brews")
ACTUAL_BREWS=$(brew list --formula -1 2>/dev/null | sort)

echo -e "${GREEN}✅ SINCRONIZADOS:${NC}"
comm -12 <(echo "$NIX_BREWS") <(echo "$ACTUAL_BREWS") | sed 's/^/  - /'

echo -e "\n${YELLOW}➕ PARA INSTALAR (Nix -> Sistema):${NC}"
comm -23 <(echo "$NIX_BREWS") <(echo "$ACTUAL_BREWS") | sed 's/^/  - /'

echo -e "\n${RED}⚠️  EXTRAS NO SISTEMA:${NC}"
comm -13 <(echo "$NIX_BREWS") <(echo "$ACTUAL_BREWS") | sed 's/^/  - /'

# --- TAPS ---
echo -e "\n${BLUE}🚰 [TAPS]${NC}"
NIX_TAPS=$(get_nix_list "taps")
ACTUAL_TAPS=$(brew tap | sort)

echo -e "${GREEN}✅ SINCRONIZADOS:${NC}"
comm -12 <(echo "$NIX_TAPS") <(echo "$ACTUAL_TAPS") | sed 's/^/  - /'

echo -e "\n${YELLOW}➕ PARA ADICIONAR (Nix -> Sistema):${NC}"
comm -23 <(echo "$NIX_TAPS") <(echo "$ACTUAL_TAPS") | sed 's/^/  - /'

echo -e "\n${RED}⚠️  EXTRAS NO SISTEMA:${NC}"
comm -13 <(echo "$NIX_TAPS") <(echo "$ACTUAL_TAPS") | sed 's/^/  - /'

echo -e "\n${BLUE}-------------------------------------------${NC}"
