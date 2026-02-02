{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_HK.UTF-8";

  services.xserver.xkb.layout = "us";

  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = ["networkmanager" "wheel"];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
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

  environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  services.openssh.enable = true;

  services.greetd.enable = true;
  services.greetd.settings.default_session = {
    command = "start-hyprland";
    user = "user";
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  networking.firewall = {
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

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.usbmuxd.enable = true;
  services.udev.extraRules = ''
    # Vial keyboards
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  system.autoUpgrade = {
    enable = true;
    flake = "git+file:///home/user/config";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "daily";
    allowReboot = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  services.mullvad-vpn.enable = true;
  networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = ["~."];
    fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    dnsovertls = "true";
  };

  system.stateVersion = "25.11";
}
