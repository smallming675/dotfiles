{modulesPath, ...}: {
  imports = [
    ./common.nix
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  networking.hostName = "nixos-iso";
  isoImage.isoName = "nixos-config.iso";
}
