{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [
        epson-escpr
      ];
      extraConf = "DefaultAuthType None";
    };
    avahi.enable = true;

    fprintd.enable = true;

    upower.enable = true;
    power-profiles-daemon.enable = true;
  };

  system.stateVersion = "26.05";
}
