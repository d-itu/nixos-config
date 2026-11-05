{ ... }: {
  imports = [ ./hardware-configuration.nix ];

  services.openssh.enable = true;

  hardware.nvidia = {
    open = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  system.stateVersion = "26.05";
}
