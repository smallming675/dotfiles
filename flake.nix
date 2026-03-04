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
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix4nvchad,
    sops-nix,
    nix-flatpak,
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
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ({config, ...}: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit nix4nvchad inputs self;};
              home-manager.sharedModules = [
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users.user = import ./home.nix;
            })
          ]
          ++ extraModules;
      };
  in {
    checks.${system} = {
      nixos-desktop = self.nixosConfigurations.desktop.config.system.build.toplevel;
      nixos-laptop = self.nixosConfigurations.laptop.config.system.build.toplevel;
      nixos-server = self.nixosConfigurations.server.config.system.build.toplevel;
    };

    nixosConfigurations = {
      desktop = mkHost {hostName = "desktop";};
      laptop = mkHost {hostName = "laptop";};
      server = mkHost {hostName = "server";};
    };
  };
}
