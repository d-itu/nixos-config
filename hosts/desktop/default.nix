{ ... }: {
  imports = [ ./hardware-configuration.nix ];

  services.openssh.enable = true;

  system.stateVersion = "26.05";
}
