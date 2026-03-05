{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
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
  
  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "media" ];
  };
  
  systemd.tmpfiles.rules = [
    "d /data/apps/jellyfin 0755 jellyfin jellyfin -"
    "d /data/media/videos 0755 root media -"
    "d /data/media/music 0755 root media -"
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/data/apps/mysql";
    ensureDatabases = ["nextcloud"];
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
    
    datadir = "/data/apps/nextcloud/data";
    database.createLocally = false;
    
    config = {
      dbtype = "mysql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbpassFile = "/etc/nextcloud-db-pass";
      dbhost = "/run/mysqld/mysqld.sock";  
      adminuser = "admin";
      adminpassFile = "/etc/nextcloud-admin-pass";
    };
    
    configureRedis = true;
    
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts mail notes tasks;
    };
    extraAppsEnable = true;
  };
  
  systemd.tmpfiles.rules = [
    "f /etc/nextcloud-db-pass 0600 nextcloud nextcloud - password"
    "f /etc/nextcloud-admin-pass 0600 nextcloud nextcloud - password"
  ];

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

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
