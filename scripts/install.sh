#!/bin/bash

# Cores para o output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Nix Setup - Residencia Apple: Iniciando instalação interativa...${NC}"

# O arquivo lido pelo Flake deve ter sempre o mesmo nome previsível
IDENTITY_FILE="identity.nix"

# 1. Identificação da Máquina (Fixo por Hardware)
if [ -f "$IDENTITY_FILE" ] && grep -q "machineId" "$IDENTITY_FILE"; then
    MACHINE_ID=$(grep "machineId =" "$IDENTITY_FILE" | cut -d'"' -f2)
    echo -e "🖥️  Máquina identificada: mac-residencia-$MACHINE_ID"
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

# 3. Geração do arquivo de identidade único
echo -e "\n${BLUE}📝 Gerando $IDENTITY_FILE...${NC}"
cat <<EOF > "$IDENTITY_FILE"
{
  machineId = "$MACHINE_ID";
  username = "$USERNAME";
  profile = "$PROFILE";
}
EOF

# OBRIGATÓRIO: Força o git a enxergar o arquivo localmente sem enviá-lo
git add -f "$IDENTITY_FILE" 
git update-index --skip-worktree "$IDENTITY_FILE"

echo -e "${GREEN}✅ Configuração salva em $IDENTITY_FILE${NC}"

# 3.5 CORREÇÃO DE PERMISSÕES DO HOMEBREW
echo -e "\n${BLUE}🔐 Ajustando permissões do Homebrew...${NC}"
# Garante que o usuário atual seja dono das pastas do Brew
if [ -d "/opt/homebrew" ]; then
    sudo chown -R "$USERNAME":admin /opt/homebrew
elif [ -d "/usr/local/Homebrew" ]; then
    sudo chown -R "$USERNAME":admin /usr/local/Homebrew
fi

# 4. Iniciar Build usando o Hostname dinâmico e MODO VERBOSE
echo -e "\n${BLUE}🛠️ Iniciando build do Nix-Darwin (com Logs detalhados)...${NC}"
if command -v darwin-rebuild &> /dev/null; then
    sudo darwin-rebuild switch --impure --flake .#"$HOSTNAME" -L --show-trace --verbose
else
    sudo nix run nix-darwin -- switch --impure --flake .#"$HOSTNAME" -L --show-trace --verbose
fi

echo -e "\n${GREEN}✨ Instalação concluída! Reinicie o terminal se necessário.${NC}"