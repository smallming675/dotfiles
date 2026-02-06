{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pix2tex-nix.url = "github:SimonYde/pix2tex.nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix4nvchad,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {inherit system;};
  in {
    nixosConfigurations.nixos = lib.nixosSystem {
      system = system;
      specialArgs = {inherit nix4nvchad;};
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit nix4nvchad inputs;};
          home-manager.users.user = import ./home.nix;
        }
      ];
    };
  };
}
