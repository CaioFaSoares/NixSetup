{
  description = "Nex residency configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, ... }@inputs:
  let
    identityFile = ./identity.nix;
    identity = if builtins.pathExists identityFile
               then import identityFile
               else { 
                 machineId = "00"; # Fallback caso falhe
                 username = "user"; 
                 profile = "suite"; 
               };
    
    # Gera o hostname dinamicamente: "mac-residencia-01", "mac-residencia-02", etc.
    dinamicHostname = "mac-residencia-${identity.machineId}";
  in {
    # Usa a variável dinamicHostname para nomear a configuração
    darwinConfigurations."${dinamicHostname}" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs identity; };
      modules = [
        ./hosts/${identity.profile}/default.nix
        ./modules/darwin/system.nix
        ./modules/darwin/apps.nix
        
        ({ pkgs, identity, ... }: {
          # Aplica o hostname na rede do macOS
          networking.hostName = dinamicHostname;
          networking.computerName = dinamicHostname; # Importante para aparecer bonitinho no AirDrop/Rede
          
          system.primaryUser = identity.username;
          
          users.users."${identity.username}" = {
            name = identity.username;
            home = "/Users/${identity.username}";
          };
          
          nix.settings.experimental-features = "nix-command flakes";
          nix.enable = false; 
        })
      ];
    };
  };
}
