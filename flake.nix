{
  description = "Nex residency configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, ... }@inputs:
  let
    # Função para gerar uma lista de IDs formatados (ex: "01", "02", ...)
    machineIds = map (n: if n < 10 then "0${toString n}" else toString n) (nixpkgs.lib.range 1 60);
    
    # Função base para criar uma configuração de máquina
    mkDarwinConfig = id: 
      let 
        identityFile = ./identity.nix;
        # Carrega a identidade local se existir, senão usa fallback
        identity = if builtins.pathExists identityFile
                   then import identityFile
                   else { machineId = id; username = "user"; profile = "suite"; };
        
        # Garante que o hostname siga o ID da configuração, mas permite sobreposição via identity.nix se necessário
        hostname = "mac-residencia-${id}";
      in darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs identity; };
        modules = [
          ./hosts/${identity.profile}/default.nix
          ./modules/darwin/system.nix
          ./modules/darwin/apps.nix
          
          ({ pkgs, identity, ... }: {
            networking.hostName = hostname;
            networking.computerName = hostname;
            system.primaryUser = identity.username;
            system.stateVersion = 6;
            
            users.users."${identity.username}" = {
              name = identity.username;
              home = "/Users/${identity.username}";
            };
            
            nix.settings.experimental-features = "nix-command flakes";
            nix.enable = false; 
          })
        ];
      };
  in {
    # Gera as configurações dinamicamente para todos os IDs
    darwinConfigurations = nixpkgs.lib.genAttrs 
      (map (id: "mac-residencia-${id}") machineIds) 
      (name: mkDarwinConfig (nixpkgs.lib.last (nixpkgs.lib.splitString "-" name)));
  };
}
