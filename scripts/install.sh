#!/bin/bash

# Cores para o output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Nix Setup - Residencia Apple: Iniciando instalação interativa...${NC}"

# 1. Identificação da Máquina (Fixo por Hardware)
# Tenta ler o ID da máquina se o identity.nix já existir
if grep -q "machineId" identity.nix 2>/dev/null; then
    MACHINE_ID=$(grep "machineId" identity.nix | cut -d'"' -f2)
    echo "🖥️  Máquina identificada: mac-residencia-$MACHINE_ID"
else
    # Se não existir, pede para o administrador/aluno digitar
    read -p "🖥️  Digite o número FÍSICO desta máquina (ex: 01, 02, 03): " MACHINE_ID
fi

HOSTNAME="mac-residencia-$MACHINE_ID"

# 2. Perguntas de Identidade (Dinâmico por Aluno)
read -p "👤 Digite seu nome de usuário (ex: seunome): " USERNAME
if [ -z "$USERNAME" ]; then
    USERNAME=$(whoami)
fi

# 2. Seleção de Perfil
echo -e "\n${BLUE}📂 Escolha o modelo de perfil:${NC}"
echo "1) designer   (Design, 3D, Edição)"
echo "2) developer  (VsCode, Dev Tools, Terminal)"
echo "3) suite      (Tudo: Designer + Developer)"
read -p "Selecione o número [1-3]: " PROFILE_OPT

case $PROFILE_OPT in
    1) PROFILE="designer" ;;
    2) PROFILE="developer" ;;
    3) PROFILE="suite" ;;
    *) PROFILE="suite"; echo "Opção inválida, usando padrão: suite" ;;
esac

# 3. Geração do identity.nix incluindo o machineId
echo -e "\n${BLUE}📝 Gerando identity.nix...${NC}"
cat <<EOF > identity.nix
{
  machineId = "$MACHINE_ID";
  username = "$USERNAME";
  profile = "$PROFILE";
}
EOF

# (Removido git add -f pois usamos --impure no build)

echo -e "${GREEN}✅ Configuração salva em identity.nix${NC}"

# 4. Iniciar Build usando o Hostname dinâmico
echo -e "\n${BLUE}🛠️ Iniciando build do Nix-Darwin...${NC}"
if command -v darwin-rebuild &> /dev/null; then
    sudo darwin-rebuild switch --impure --flake .#"$HOSTNAME"
else
    sudo nix run nix-darwin -- switch --impure --flake .#"$HOSTNAME"
fi

echo -e "\n${GREEN}✨ Instalação concluída! Reinicie o terminal se necessário.${NC}"
