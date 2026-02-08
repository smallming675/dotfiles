{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nixos/common.nix
    ./hardware-configuration.nix
  ];

  config = {
    networking.hostName = "laptop";
    networking.networkmanager.wifi.backend = "iwd";
  };
}
