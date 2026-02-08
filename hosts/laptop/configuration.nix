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

    networking.wireless.enable = false;
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

    networking.networkmanager.ensureProfiles = {
      profiles = {
        home = {
          connection = {
            id = "home";
            type = "wifi";
            autoconnect = true;
            autoconnect-priority = 100;
          };
          wifi = {
            mode = "infrastructure";
            ssid = "Chan 5G";
            hidden = true;
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "7e2d032fb54aef1e730d11a2c93fcd2bab0452d480681d737684eba5ffb3008c";
          };
          ipv4.method = "auto";
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
        };
      };
    };
  };
}
