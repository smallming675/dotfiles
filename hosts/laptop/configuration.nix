{inputs, ...}: {
  imports = [
    ../../modules/nixos/common.nix
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
  ];

  networking.hostName = "laptop";
  networking.networkmanager.wifi.backend = "iwd";
}
