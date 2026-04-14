#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}🛡️ Nex: Atualizando sistema...${NC}"

# Extrair machineId atual
CURR_ID=$(grep "machineId =" identity.nix | cut -d'"' -f2)
HOSTNAME="mac-residencia-$CURR_ID"

if [ -z "$CURR_ID" ]; then
    echo "Erro: Não foi possível determinar o machineId em identity.nix"
    exit 1
fi

nix flake update
sudo darwin-rebuild switch --impure --flake .#"$HOSTNAME"

echo -e "${GREEN}✨ Sistema atualizado com sucesso!${NC}"
