{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../modules/nixos/common.nix
    ./hardware-configuration.nix
  ];

  config = {
    my.userName = "user";
    networking.hostName = "laptop";

    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      secrets."wifi/home_psk" = {};
      templates."nm-home".content = ''
        [connection]
        id=home
        type=wifi
        autoconnect=true
        autoconnect-priority=100

        [wifi]
        mode=infrastructure
        ssid=Chan 5G
        hidden=true

        [wifi-security]
        key-mgmt=wpa-psk
        psk=${config.sops.placeholder."wifi/home_psk"}

        [ipv4]
        method=auto

        [ipv6]
        addr-gen-mode=stable-privacy
        method=auto
      '';
    };

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

    environment.etc."NetworkManager/system-connections/home.nmconnection" = {
      source = config.sops.templates."nm-home".path;
      mode = "0600";
    };
  };
}
