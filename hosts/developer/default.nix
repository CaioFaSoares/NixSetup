# Perfil: Developer (IDEs, Docker, Dev Tools)
{ pkgs, identity, ... }:

{
  nex.darwin.apps = {
    essentials.enable = true;
    dev.enable        = true;
    designer.enable   = false;
    social.enable     = true;
    utils.enable      = true;
  };

  system.activationScripts.postActivation.text = ''
    echo "🛠️ Nex: Configurando ambiente Developer para ${identity.username}..."
    if [ -d "/Applications/Xcode.app" ]; then
      xcode-select -s /Applications/Xcode.app/Contents/Developer
      xcodebuild -license accept
    else
      echo "⚠️ Xcode.app não encontrado em /Applications. Pulando configuração."
    fi
  '';
}