{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix4nvchad.url = "github:nix-community/nix4nvchad";
    nix4nvchad.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix4nvchad,
    sops-nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    mkHost = {
      hostName ? null,
      hostConfig ? (
        if hostName == null
        then null
        else ./hosts/${hostName}/configuration.nix
      ),
      extraModules ? [],
    }:
      lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit nix4nvchad inputs self;
        };
        modules =
          (lib.optionals (hostConfig != null) [hostConfig])
          ++ [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ({config, ...}: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit nix4nvchad inputs self;
                flakeDir = config.my.flakeDir;
              };
              home-manager.sharedModules = [
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users.${config.my.userName} = import ./home.nix;
            })
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations = {
      desktop = mkHost {hostName = "desktop";};
      laptop = mkHost {hostName = "laptop";};
      iso = mkHost {
        hostConfig = ./modules/nixos/iso.nix;
      };
    };
  };
}
