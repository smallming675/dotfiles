{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nixos/common.nix
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
  ];

  config = {
    networking.hostName = "laptop";
    networking.networkmanager.wifi.backend = "iwd";

    # Keep the patched linux-surface kernel.
    hardware.microsoft-surface.kernelVersion = "longterm";

    environment.systemPackages = with pkgs; [
      surface-control
    ];

    users.users.user.extraGroups = ["surface-control"];

    services.xserver.videoDrivers = ["modesetting"];
  };
}
