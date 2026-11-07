{
  config,
  ...
}:
{
  imports = [
    ./dae
    ./sometimes.nix
  ];
  services.dae.enable = true;

  networking.proxy.nodes =
    let
      ph = config.sops.placeholder;
    in
    {
      naive = {
        protocol = "naive";
        host = ph."proxy_node/host";
        user = ph."proxy_node/user";
        password = ph."proxy_node/password";
      };
    };

  sops.secrets = {
    "proxy_node/user" = {
      sopsFile = ./secrets/proxy_node.yaml;
      key = "user";
    };
    "proxy_node/host" = {
      sopsFile = ./secrets/proxy_node.yaml;
      key = "host";
    };
    "proxy_node/password" = {
      sopsFile = ./secrets/proxy_node.yaml;
      key = "password";
    };
  };
}
