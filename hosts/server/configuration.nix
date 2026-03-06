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
  };

  systemd.tmpfiles.rules = [
    "d /data/apps/jellyfin 0755 jellyfin jellyfin -"
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
      umask = 2;                     
      rpc-bind-address = "0.0.0.0";
      rpc-authentication-required = false;  
      rpc-whitelist = "127.0.0.1,::1,192.168.*.*";   
      rpc-whitelist-enabled = true;
    };
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
