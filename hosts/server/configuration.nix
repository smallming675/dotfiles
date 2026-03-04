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
  ];

  services.openssh.enable = true;

  system.copySystemConfiguration = true;
  system.stateVersion = "25.11";

  networking.firewall.allowedTCPPorts = [80 443 8096 22];
  networking.firewall.allowedUDPPorts = [80 443 8096 22];
}
