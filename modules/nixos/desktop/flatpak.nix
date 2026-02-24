{...}: {
  services.flatpak = {
    enable = true;
    packages = [
      "org.prismlauncher.PrismLauncher"
    ];
  };
}
