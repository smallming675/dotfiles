{pkgs, lib, ...}:
let
  syncDir = "/home/user/sync";
  userName = "user";
  nextcloudDomain = "oceu.tech";
in
{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop/flatpak.nix
    ./hardware-configuration.nix
  ];
  my.userName = "user";
  my.nextcloudDomain = "oceu.tech";
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
    "d ${syncDir} 0755 user users -"
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
  environment.systemPackages = with pkgs; [ rsync openssh ];

  systemd.user.services.nextcloud-rsync = {
    description = "Sync to nextcloud";
    after = [ "network.target" ];
    wantedBy = [ "timers.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      User = userName;
      Group = "users";
      ExecStart = "${pkgs.rsync}/bin/rsync -avz -e ssh ${syncDir}/ ${userName}@${nextcloudDomain}:/home/${userName}/sync/";
    };
  };

  systemd.user.timers.nextcloud-rsync = {
    description = "Hourly rsync to Nextcloud timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "nextcloud-rsync.service";
    };
  };
  services.xserver.videoDrivers = ["nvidia"];
}
