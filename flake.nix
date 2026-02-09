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
    nixos-hardware.url = "github:8bitbuddhist/nixos-hardware/ac6458d3bcef09b40317be72e2b4f3795936732c";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix4nvchad,
    sops-nix,
    nixos-hardware,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    mkHost = {
      hostName,
      extraModules ? [],
    }:
      lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit nix4nvchad inputs self;
        };
        modules =
          [
            ./hosts/${hostName}/configuration.nix
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ({config, ...}: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit nix4nvchad inputs self;};
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
        hostName = "desktop";
        extraModules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          {
            isoImage.isoName = "nixos-config.iso";
          }
        ];
      };
    };
  };
}
