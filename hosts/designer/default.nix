# Perfil: Designer (Criativo, 3D, Edição)
{ pkgs, identity, ... }:

{
  nex.darwin.apps = {
    essentials.enable = true;
    dev.enable        = false;
    designer.enable   = true;
    social.enable     = true;
    utils.enable      = true;
  };

  system.activationScripts.postActivation.text = ''
    echo "🛠️ Nex: Configurando ambiente Designer para ${identity.username}..."
    if [ -d "/Applications/Xcode.app" ]; then
      xcode-select -s /Applications/Xcode.app/Contents/Developer
      xcodebuild -license accept
    else
      echo "⚠️ Xcode.app não encontrado em /Applications. Pulando configuração."
    fi
  '';
}