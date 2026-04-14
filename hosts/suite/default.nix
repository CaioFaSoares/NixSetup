# Perfil: Suite (Tudo incluso: Dev + Designer)
{ pkgs, identity, ... }:

{
  nex.darwin.apps = {
    essentials.enable = true;
    dev.enable        = true;
    designer.enable   = true;
    social.enable     = true;
    utils.enable      = true;
  };

  system.activationScripts.postActivation.text = ''
    echo "🛠️ Nex: Configurando ambiente Suite para ${identity.username}..."
    if [ -d "/Applications/Xcode.app" ]; then
      xcode-select -s /Applications/Xcode.app/Contents/Developer
      xcodebuild -license accept
    else
      echo "⚠️ Xcode.app não encontrado em /Applications. Pulando configuração."
    fi
  '';
}