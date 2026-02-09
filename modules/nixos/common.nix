{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.my;
in {
  options.my = {
    userName = lib.mkOption {
      type = lib.types.str;
      default = "user";
    };
  };

  config = {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      steam-hardware.enable = true;
    };

    networking = {
      networkmanager.enable = true;

      firewall = {
        enable = true;
        allowedTCPPorts = [
          53317
          8384
          22000
        ];
        allowedUDPPorts = [
          53317
          22000
        ];
      };

      nameservers = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
    };

    services = {
      resolved = {
        enable = true;
        settings = {
          Resolve = {
            dnsovertls = "true";
            dnssec = "true";
            domains = ["~."];
            fallbackDns = [
              "1.1.1.1#one.one.one.one"
              "1.0.0.1#one.one.one.one"
            ];
          };
        };
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      mullvad-vpn.enable = true;
    };

    time.timeZone = "Asia/Hong_Kong";
    i18n.defaultLocale = "en_HK.UTF-8";
    services.xserver.xkb.layout = "us";

    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = cfg.userName;
      extraGroups = ["networkmanager" "wheel"];
    };

    environment = {
      systemPackages = with pkgs; [
        vial
        vim
        wget
        curl
        htop
        zip
        unzip
        openssh
        gcc
        gnumake
        pkg-config
        cmake
        python3
        nodejs
        go
        clang-tools
      ];

      pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];

      variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        MANPAGER = "nvim +Man!";
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        QT_STYLE_OVERRIDE = "";
      };
    };

    nixpkgs.config.allowUnfree = true;

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      nerd-fonts.jetbrains-mono
      dina-font
      proggyfonts
    ];

    services.pcscd.enable = true;

    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
      enableSSHSupport = true;
    };

    services.openssh.enable = true;

    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "start-hyprland";
        user = cfg.userName;
      };
    };

    sops = {
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
    };

    nix = {
      settings.experimental-features = ["nix-command" "flakes"];

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [];
    };

    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      dates = "02:00";
      randomizedDelaySec = "45min";
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [gutenprint gutenprintBin];
      listenAddresses = ["localhost:631"];
      allowFrom = ["all"];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
      browsed.enable = true;
    };

    services.ipp-usb.enable = true;

    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    services.usbmuxd.enable = true;
    system.stateVersion = "25.11";
  };
}
