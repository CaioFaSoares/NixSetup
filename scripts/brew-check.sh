#!/usr/bin/env bash
# scripts/brew-check.sh

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 0. Verificação de Permissões Críticas
if [ -f "flake.lock" ]; then
    owner=$(ls -l flake.lock | awk '{print $3}')
    if [ "$owner" == "root" ]; then
        echo -e "${RED}❌ Erro de Permissão: O arquivo 'flake.lock' pertence ao root.${NC}"
        echo -e "${YELLOW}Para resolver, execute o seguinte comando e tente novamente:${NC}"
        echo -e "${BLUE}   sudo chown $(whoami) flake.lock${NC}\n"
        exit 1
    fi
fi

# 1. Detecção do Hostname alvo
if [ -f "identity.nix" ]; then
    MACHINE_ID=$(grep "machineId =" identity.nix | cut -d'"' -f2)
    LOCAL_TARGET="mac-residencia-$MACHINE_ID"
else
    LOCAL_TARGET=$(scutil --get LocalHostName 2>/dev/null || hostname -s)
fi

TARGET_HOST=${1:-$LOCAL_TARGET}

echo -e "${BLUE}🔍 Analisando desvios do Homebrew para '${TARGET_HOST}'...${NC}"

# 2. Busca de dados do Nix em uma única chamada (mais rápido)
echo -e "${BLUE}⏳ Coletando dados da configuração Nix (isso pode levar alguns segundos)...${NC}"
NIX_JSON=$(nix eval --impure --json .#darwinConfigurations."$TARGET_HOST".config.homebrew 2>/dev/null)

if [ -z "$NIX_JSON" ]; then
    echo -e "${RED}❌ Erro: Não foi possível avaliar a configuração do Nix para '$TARGET_HOST'.${NC}"
    echo -e "Verifique se o hostname está correto e se o seu flake.nix está sem erros."
    exit 1
fi

# Função auxiliar para formatar listas do JSON
format_list() {
    echo "$NIX_JSON" | jq -r ".${1} | .[] | if type == \"string\" then . else .name end" | sort
}

# --- CASKS ---
echo -e "\n${BLUE}📦 [CASKS]${NC}"
NIX_CASKS=$(format_list "casks")
ACTUAL_CASKS=$(brew list --cask -1 2>/dev/null | sort)

echo -e "${GREEN}✅ SINCRONIZADOS:${NC}"
comm -12 <(echo "$NIX_CASKS") <(echo "$ACTUAL_CASKS") | sed 's/^/  - /'

echo -e "\n${YELLOW}➕ PARA INSTALAR (Nix -> Sistema):${NC}"
comm -23 <(echo "$NIX_CASKS") <(echo "$ACTUAL_CASKS") | sed 's/^/  - /'

echo -e "\n${RED}⚠️  EXTRAS NO SISTEMA (Serão removidos no cleanup do Nix):${NC}"
comm -13 <(echo "$NIX_CASKS") <(echo "$ACTUAL_CASKS") | sed 's/^/  - /'

# --- BREWS (Formulae) ---
echo -e "\n${BLUE}🍺 [BREWS]${NC}"
NIX_BREWS=$(format_list "brews")
ACTUAL_BREWS=$(brew list --formula -1 2>/dev/null | sort)

echo -e "${GREEN}✅ SINCRONIZADOS:${NC}"
comm -12 <(echo "$NIX_BREWS") <(echo "$ACTUAL_BREWS") | sed 's/^/  - /'

echo -e "\n${YELLOW}➕ PARA INSTALAR (Nix -> Sistema):${NC}"
comm -23 <(echo "$NIX_BREWS") <(echo "$ACTUAL_BREWS") | sed 's/^/  - /'

echo -e "\n${RED}⚠️  EXTRAS NO SISTEMA:${NC}"
comm -13 <(echo "$NIX_BREWS") <(echo "$ACTUAL_BREWS") | sed 's/^/  - /'

# --- TAPS ---
echo -e "\n${BLUE}🚰 [TAPS]${NC}"
NIX_TAPS=$(format_list "taps")
ACTUAL_TAPS=$(brew tap | sort)

echo -e "${GREEN}✅ SINCRONIZADOS:${NC}"
comm -12 <(echo "$NIX_TAPS") <(echo "$ACTUAL_TAPS") | sed 's/^/  - /'

echo -e "\n${YELLOW}➕ PARA ADICIONAR (Nix -> Sistema):${NC}"
comm -23 <(echo "$NIX_TAPS") <(echo "$ACTUAL_TAPS") | sed 's/^/  - /'

echo -e "\n${RED}⚠️  EXTRAS NO SISTEMA:${NC}"
comm -13 <(echo "$NIX_TAPS") <(echo "$ACTUAL_TAPS") | sed 's/^/  - /'

echo -e "\n${BLUE}-------------------------------------------${NC}"
