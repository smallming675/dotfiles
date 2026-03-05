{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nixos/common.nix
    ./hardware-configuration.nix
  ];

  config = {
    my.userName = "user";
    networking.hostName = "laptop";

    time.timeZone = "Asia/Hong_Kong";
    i18n.defaultLocale = "en_HK.UTF-8";
    services.xserver.xkb.layout = "us";

    sops.age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/sops-nix 0750 root users -"
      "z /var/lib/sops-nix/key.txt 0640 root users -"
    ];

    services.printing = {
      enable = true;
      drivers = with pkgs; [gutenprint gutenprintBin];
      listenAddresses = ["localhost:631"];
      browsing = true;
      defaultShared = true;
      openFirewall = false;
      browsed.enable = true;
    };

    services.ipp-usb.enable = true;

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
