{
  config,
  ...
}:
{
  sops = {
    secrets = {
      "sops/age/keys.txt" = {
        sopsFile = ./secrets/keys.txt;
        path = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        format = "binary";
      };
    };
  };
}
