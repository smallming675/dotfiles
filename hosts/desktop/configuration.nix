{...}: {
  imports = [
    ../../modules/nixos/common.nix
    ./hardware-configuration.nix
  ];

  my.userName = "user";
  networking.hostName = "desktop";

  services.flatpak = {
    enable = true;
    packages = [
      "org.prismlauncher.PrismLauncher"
    ];
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
