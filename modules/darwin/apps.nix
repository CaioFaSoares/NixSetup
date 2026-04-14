# modules/darwin/apps.nix
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nex.darwin.apps;
in {
  # 1. DEFINIÇÃO DAS OPÇÕES (Interruptores)
  options.nex.darwin.apps = {
    essentials.enable = mkOption { type = types.bool; default = true; description = "Navegadores e utilitários críticos."; };
    dev.enable = mkEnableOption "Ferramentas de Desenvolvimento Visual (IDE, Docker, etc).";
    designer.enable = mkEnableOption "Design, 3D e Edição de Vídeo/Áudio.";
    social.enable = mkEnableOption "Comunicação e Notas (Discord, Notion, etc).";
    utils.enable = mkEnableOption "Utilitários de Sistema e Hardware.";
  };

  # 2. CONFIGURAÇÃO BASE DO HOMEBREW
  config.homebrew = {
    enable = true;
    onActivation.cleanup = "none";

    brews = [
      # "fetchx"
    ];

    # 3. MAPEAMENTO CONDICIONAL DOS CASKS
    casks = []
      # --- ESSENCIAIS (Sempre ativos ou via chave) ---
      ++ optionals cfg.essentials.enable [
        "google-chrome"
      ]

      # --- DESENVOLVIMENTO ---
      ++ optionals cfg.dev.enable [
        "visual-studio-code"
        "ghostty"
        "insomnia"
        "tuist"
      ]

      # --- CRIATIVO (DESIGN, 3D, VÍDEO) ---
      ++ optionals cfg.designer.enable [
        "blender"
        "canva"
        "affinity"
        "figma"
        "sf-symbols"
        "obs"
        "shutter-encoder"
        "vlc"
      ]

      # --- SOCIAL & PRODUTIVIDADE ---
      ++ optionals cfg.social.enable [
        "notion"
        "discord"
        "whatsapp"
      ]

      # --- SISTEMA & UTILITÁRIOS ---
      ++ optionals cfg.utils.enable [
        "alfred"
        "zerotier-one"
        "bluesnooze"
        "keyboardcleantool"
        "the-unarchiver"
        "grandperspective"
      ]
  };
}