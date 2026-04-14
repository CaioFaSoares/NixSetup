#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}🛡️ Nex: Atualizando sistema...${NC}"

# Tenta localizar o arquivo identity-*.nix
IDENTITY_FILE=$(ls identity-*.nix 2>/dev/null | head -n 1)

if [ -z "$IDENTITY_FILE" ]; then
    echo "Erro: Arquivo de identidade não encontrado."
    exit 1
fi

# Extrair machineId atual
CURR_ID=$(grep "machineId =" "$IDENTITY_FILE" | cut -d'"' -f2)
HOSTNAME="mac-residencia-$CURR_ID"

nix flake update
sudo darwin-rebuild switch --impure --flake .#"$HOSTNAME"

echo -e "${GREEN}✨ Sistema atualizado com sucesso!${NC}"
