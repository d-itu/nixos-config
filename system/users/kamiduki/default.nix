{
  pkgs,
  lib,
  ...
}:
let
  username = baseNameOf (lib.removeSuffix "/default.nix" ./.);
in
{
  home-manager.users."${username}" = {
    imports = [ ./home ];

    home = {
      inherit username;
      homeDirectory = "/home/${username}";
    };
  };

  users.users."${username}" = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
    ];
    uid = 1000;
  };

  services.displayManager.noctalia-greeter.passwordlessSyncUsers = [ username ];
}
