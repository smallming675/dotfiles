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

  my.config.my.nextcloudDomain = "oceu.tech";

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
    # TODO: set password with `passwd user` after first boot
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
  };

  systemd.tmpfiles.rules = [
    "d /data/apps/jellyfin 0755 jellyfin jellyfin -"
    "d /data/apps/nextcloud 0750 nextcloud nextcloud -"
    "d /data/media/videos 0755 root media -"
    "d /data/media/music 0755 root media -"
    "d /data/media/torrents 0755 transmission transmission -"
  ];
  
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  users.users.transmission.extraGroups = [ "media" ];

  services.transmission = {
    enable = true;
    openFirewall = true;  
    settings = {
      download-dir = "/data/media/videos";
      watch-dir = "/data/media/torrents";
      incomplete-dir-enabled = false; 
      umask = 2;                     
      rpc-bind-address = "0.0.0.0";
      rpc-authentication-required = false;  
      rpc-whitelist = "127.0.0.1,::1,192.168.*.*";   
      rpc-whitelist-enabled = true;
    };
  };

  services.openssh.enable = true;

  sops.secrets.nextcloud_admin_password = {
    owner = "nextcloud";
    group = "nextcloud";
    mode = "0400";
  };

  services.nextcloud = {
    enable = true;
    hostName = config.my.nextcloudDomain;
    https = true;
    datadir = "/data/apps/nextcloud";
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
    };
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts tasks onlyoffice notes;
    };
    autoUpdateApps.enable = false;  
    extraAppsEnable = true;
    settings = {
      overwriteprotocol = "https";
      maintenance_window_start = 2;
    };
  };

  # Disable nextcloud-setup after initial install to prevent rebuild failures
  systemd.services.nextcloud-setup.enable = false;

  services.postgresqlBackup = {
    enable = true;
    databases = [ "nextcloud" ];
    location = "/data/backups/postgresql";
    startAt = "*-*-* 01:15:00";
    compression = "zstd";
  };

  services.nginx = {
    enable = true;
    virtualHosts.${config.my.nextcloudDomain} = {
      enableACME = true;
      forceSSL = true;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@${config.my.nextcloudDomain}";
  };

  system.stateVersion = "25.11";

  services.nextcloud.settings.trusted_domains = [
    config.my.nextcloudDomain
  ];

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
