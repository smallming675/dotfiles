{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["zfs"];

  networking.hostName = "server";
  networking.hostId = "8425e349";
  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;

  boot.zfs.extraPools = ["tank"];  
  services.zfs.autoSnapshot.enable = true;  
  services.zfs.autoScrub.enable = true;    
  services.zfs.trim.enable = true;  


  users.groups.media = {};
  users.users.user = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    initialPassword = "changeme";
    packages = with pkgs; [];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    zfs  
    htop
    btop
    rsync
    file
    ncdu
    borgbackup  
  ];

  fileSystems."/data/media" = {
    device = "tank/media";
    fsType = "zfs";
  };
  
  fileSystems."/data/apps" = {
    device = "tank/apps";
    fsType = "zfs";
  };
  
  fileSystems."/data/backups" = {
    device = "tank/backups";
    fsType = "zfs";
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    age = { 
      keyFile = "/var/lib/sops-nix/key.txt";
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = true;
    };
    
    secrets = {
      "nextcloud_admin_password" = {
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0400";
      };
      
      "nextcloud_db_password" = {
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0400";
      };
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/data/apps/mysql";
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions = {
          "nextcloud.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.nextcloud = {
    enable = true;
    hostName = "localhost";
    database.createLocally = false;
    datadir = "/data/apps/nextcloud/data";
    
    config = {
      dbtype = "mysql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbpassFile = config.sops.secrets."nextcloud_db_password".path;
      dbhost = "/run/mysqld/mysqld.sock";
      adminuser = "admin";
      adminpassFile = config.sops.secrets."nextcloud_admin_password".path;
    };
    
    configureRedis = true;
    
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts mail notes tasks;
    };
    extraAppsEnable = true;
  };

  systemd.tmpfiles.rules = [
    "d /data/apps/jellyfin 0755 jellyfin jellyfin -"
    "d /data/media/videos 0755 root media -"
    "d /data/media/music 0755 root media -"
  ];
  
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  systemd.services.nextcloud-setup = {
    requires = [ "sops-install-secrets.service" ];
    after = [ "sops-install-secrets.service" ];
  };
  
  systemd.services.phpfpm-nextcloud = {
    requires = [ "sops-install-secrets.service" ];
    after = [ "sops-install-secrets.service" ];
  };
  
  services.openssh.enable = true;

  system.stateVersion = "25.11";

  networking.firewall.allowedTCPPorts = [
    80    # HTTP (Nextcloud)
    443   # HTTPS
    8096  # Jellyfin
    22    # SSH
    8384  # Syncthing
    22000 # Syncthing
    9091  # Transmission
    3000  # Grafana
    8222  # Vaultwarden
  ];
  
  networking.firewall.allowedUDPPorts = [
    22000 # Syncthing
    21027 # Syncthing discovery
  ];
}
