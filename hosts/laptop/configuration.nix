{...}: {
  imports = [
    ../../modules/nixos/common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";

  # Change this if your laptop uses NVIDIA.
  services.xserver.videoDrivers = ["modesetting"];
}
