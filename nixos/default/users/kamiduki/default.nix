{
  pkgs,
  lib,
  ...
}:
let
  username = baseNameOf (lib.removeSuffix "/default.nix" ./.);
  homeDirectory = "/home/${username}";
in
{
  home-manager.users."${username}" = {
    imports = [ ./home ];

    home = {
      inherit username homeDirectory;
      file.".ssh/id_ed25519.pub".source = ./id_ed25519.pub;
    };
  };

  users.users."${username}" = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
    ];
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_ed25519.pub)
    ];
    uid = 1000;
  };

  sops = {
    secrets = {
      "${username}/id_ed25519" = {
        sopsFile = ./secrets/id_ed25519;
        path = "${homeDirectory}/.ssh/id_ed25519";
        format = "binary";
        owner = username;
      };
    };
  };

  services.displayManager.noctalia-greeter.passwordlessSyncUsers = [ username ];
}
