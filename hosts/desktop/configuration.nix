{config, ...}: {
  imports = [
    ../../modules/nixos/common.nix
    ./hardware-configuration.nix
  ];

  my.userName = "user";
  networking.hostName = "desktop";

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-uuid/efd88dc0-0879-4879-b54b-ca563128123a";
    fsType = "ext4";
    options = ["nofail" "x-systemd.automount" "x-systemd.idle-timeout=10min"];
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets."borg/passphrase" = {
      owner = "root";
      mode = "0400";
    };
  };

  services.borgbackup.jobs.home = {
    paths = ["/home/${config.my.userName}"];
    repo = "/mnt/backup";
    doInit = true;
    compression = "zstd,6";
    startAt = "daily";
    persistentTimer = true;

    encryption = {
      mode = "keyfile-blake2";
      passCommand = ''cat ${config.sops.secrets."borg/passphrase".path}'';
    };

    environment.BORG_BASE_DIR = "/var/lib/borg";
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };

  services.xserver.videoDrivers = ["nvidia"];
}
