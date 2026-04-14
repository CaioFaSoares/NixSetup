#!/bin/bash

# Cores
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ ! -f "identity.nix" ]; then
    echo -e "${BLUE}❌ identity.nix não encontrado. Rode o install.sh primeiro.${NC}"
    exit 1
fi

# Extrair username e hostname atuais (gambiarra simples com grep/sed)
CURR_USER=$(grep "username =" identity.nix | cut -d'"' -f2)
CURR_HOST=$(grep "hostname =" identity.nix | cut -d'"' -f2)

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
  username = "$CURR_USER";
  hostname = "$CURR_HOST";
  profile = "$NEW_PROFILE";
}
EOF

echo -e "${GREEN}✅ Perfil alterado para: $NEW_PROFILE${NC}"
echo -e "${BLUE}⚙️ Aplicando alterações...${NC}"

sudo darwin-rebuild switch --impure --flake .#"$CURR_HOST"

echo -e "${GREEN}✨ Pronto! Perfil $NEW_PROFILE ativado.${NC}"
