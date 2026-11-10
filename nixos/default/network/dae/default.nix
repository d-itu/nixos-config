{
  lib,
  config,
  ...
}:
{
  services.dae = {
    configFile = config.sops.templates."config.dae".path;
  };

  sops.templates =
    let
      nodes =
        config.networking.proxy.nodes
        |> lib.mapAttrsToList (name: node: "${name}: '${node.url}'")
        |> lib.concatStringsSep "\n";
    in
    {
      "config.dae" = lib.mkIf config.services.dae.enable {
        content = builtins.readFile ./config.dae + " node { ${nodes} } ";
        reloadUnits = [ "dae.service" ];
      };
    };
}
