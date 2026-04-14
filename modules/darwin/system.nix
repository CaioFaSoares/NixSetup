{ pkgs, ... }:

{
  # Configurações básicas de sistema do macOS
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmb";
    loginwindow.GuestEnabled = false;
  };

  # Ativar teclado PT-BR e outras configurações se necessário
  # system.keyboard.enableKeyMapping = true;
}
