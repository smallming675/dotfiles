{pkgs, ...}: {
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop/flatpak.nix
    ./hardware-configuration.nix
  ];

  my.userName = "user";
  networking.hostName = "desktop";

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

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };
  virtualisation.docker.enable = true;
  users.users.user.extraGroups = [ "docker" ];

  services.xserver.videoDrivers = ["nvidia"];
}
