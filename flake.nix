{
  description = "Nex residency configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, ... }@inputs:
  let
    # Carrega a identidade se existir, senão usa defaults
    identityFile = ./identity.nix;
    identity = if builtins.pathExists identityFile
               then import identityFile
               else { 
                 username = "user"; 
                 hostname = "macbook"; 
                 profile = "suite"; 
               };
  in {
    darwinConfigurations."${identity.hostname}" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs identity; };
      modules = [
        ./hosts/${identity.profile}/default.nix
        ./modules/darwin/system.nix
        ./modules/darwin/apps.nix
        
        # Módulo de identidade dinâmica
        ({ pkgs, identity, ... }: {
          networking.hostName = identity.hostname;
          system.primaryUser = identity.username;
          
          users.users."${identity.username}" = {
            name = identity.username;
            home = "/Users/${identity.username}";
          };
          
          # Configurações de Nix comuns
          nix.settings.experimental-features = "nix-command flakes";
          # Impede o nix-darwin de tentar gerenciar o Nix se já estiver instalado por outros meios (ajustar se necessário)
          nix.enable = false; 
        })
      ];
    };
  };
}
