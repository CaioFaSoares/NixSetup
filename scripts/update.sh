#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}🛡️ Nex: Atualizando sistema...${NC}"

# Extrair hostname atual
CURR_HOST=$(grep "hostname =" identity.nix | cut -d'"' -f2)

if [ -z "$CURR_HOST" ]; then
    echo "Erro: Não foi possível determinar o hostname em identity.nix"
    exit 1
fi

nix flake update
sudo darwin-rebuild switch --flake .#$CURR_HOST

echo -e "${GREEN}✨ Sistema atualizado com sucesso!${NC}"
