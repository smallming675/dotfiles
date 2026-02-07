{
  config,
  pkgs,
  inputs,
  ...
}: let
  user = "user";
  path = "/home/${user}/config";
in {
  imports = [./hardware-configuration.nix];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware = {
    # Graphics & NVIDIA
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };

    # Steam hardware support
    steam-hardware.enable = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        53317 # localsend
        8384 # syncthing gui
        22000 # syncthing
      ];
      allowedUDPPorts = [
        53317 # localsend
        22000 # syncthing
      ];
    };

    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
  };

  services = {
    # DNS resolution
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

    # Network discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    # VPN
    mullvad-vpn.enable = true;
  };

  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_HK.UTF-8";
  services.xserver.xkb.layout = "us";

  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = ["networkmanager" "wheel"];
  };

  environment = {
    systemPackages = with pkgs; [
      # System utilities
      vial
      vim
      wget
      curl
      htop
      zip
      unzip
      openssh

      # Development tools
      gcc
      gnumake
      pkg-config
      cmake
      python3
      nodejs
      go
      clang-tools

      # Libraries (fix for libstdc++.so.6)
      glibc
      stdenv.cc.cc.lib
      pkgsi686Linux.glibc
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
    # Vial keyboards
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "start-hyprland";
      user = user;
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

  system.autoUpgrade.enable = false;

  systemd = {
    services.nixos-auto-update = {
      description = "NixOS Auto Update";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      script = ''
        ${pkgs.nix}/bin/nix flake update --flake ${path}
        echo "Rebuilding system..."
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${path} -L
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    timers.nixos-auto-update = {
      description = "Nixos Auto Update";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "02:00";
        RandomizedDelaySec = "45min";
        Persistent = true;
        Unit = "nixos-auto-update.service";
      };
    };
  };

  programs.git = {
    enable = true;
    config = {
      safe.directory = [path];
    };
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

  virtualisation.docker.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.usbmuxd.enable = true;

  system.stateVersion = "25.11";
}
