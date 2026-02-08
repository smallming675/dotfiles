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

    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";
    networking.wireless.iwd.settings = {
      Settings = {
        AutoConnect = true;
        AlwaysRandomizeAddress = false;
      };
      IPv6 = {
        Enabled = true;
        PrivacyPreferred = true;
      };
    };

    networking.wireless.networks = {
      "Chan 5G" = {
        psk = "7e2d032fb54aef1e730d11a2c93fcd2bab0452d480681d737684eba5ffb3008c";
        hidden = true;
        priority = 100;
      };
    };
  };
}
