{ config, pkgs, lib, inputs, ... }:
let
  userName = "user";
  syncDir = "/home/${userName}/sync";
in {
  imports = [
    ../../modules/nixos/common.nix
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops  
  ];

  services.flatpak = {
    enable = true;
    packages = [
      "org.prismlauncher.PrismLauncher"
    ];
  };

  my.userName = "user";
  networking.hostName = "desktop";

  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_HK.UTF-8";
  services.xserver.xkb.layout = "us";

  sops = {
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets."borg/passphrase" = {
      owner = "root";
    };
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

  services.xserver.videoDrivers = ["nvidia"];

  services.borgbackup.jobs = {
    "backup" = {
      paths = [ "/home" ];
      exclude = [
        "'*/.cache'"
        "'*/.local/share/Trash'"
      ];
      repo = "ssh://borg@oceu.tech:22/./borg/backups/borg";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."borg/passphrase".path}";
      };

      compression = "auto,lzma";
      startAt = "daily";
      environment = {
        BORG_RSH = "ssh -i /home/user/.ssh/id_ed25519_backup -o StrictHostKeyChecking=yes";
      };
      
      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };
  };
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;  
}

