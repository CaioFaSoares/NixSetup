#!/bin/bash

# Cores
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ ! -f "identity.nix" ]; then
    echo -e "${BLUE}❌ identity.nix não encontrado. Rode o install.sh primeiro.${NC}"
    exit 1
fi

# Extrair machineId e username atuais
CURR_ID=$(grep "machineId =" identity.nix | cut -d'"' -f2)
CURR_USER=$(grep "username =" identity.nix | cut -d'"' -f2)
HOSTNAME="mac-residencia-$CURR_ID"

echo -e "${BLUE}🔄 Nex: Trocando modelo de perfil...${NC}"
echo "1) designer"
echo "2) developer"
echo "3) suite"
read -p "Escolha o novo perfil [1-3]: " NEW_OPT

case $NEW_OPT in
    1) NEW_PROFILE="designer" ;;
    2) NEW_PROFILE="developer" ;;
    3) NEW_PROFILE="suite" ;;
    *) echo "Operação cancelada."; exit 0 ;;
esac

# Atualizar identity.nix
cat <<EOF > identity.nix
{
  machineId = "$CURR_ID";
  username = "$CURR_USER";
  profile = "$NEW_PROFILE";
}
EOF

# Garantir que o git continue ignorando mudanças locais no arquivo
git add -f identity.nix 
git update-index --skip-worktree identity.nix

echo -e "${GREEN}✅ Perfil alterado para: $NEW_PROFILE${NC}"
echo -e "${BLUE}⚙️ Aplicando alterações...${NC}"

sudo darwin-rebuild switch --impure --flake .#"$HOSTNAME"

echo -e "${GREEN}✨ Pronto! Perfil $NEW_PROFILE ativado.${NC}"
