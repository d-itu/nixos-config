{
  lib,
  ...
}:
let
  node = lib.types.submodule (
    { config, ... }: {
      options = with config; {
        url = lib.mkOption {
          type = lib.types.str;
          default = "${scheme}://${user}:${password}@${host}";
        };
        scheme = lib.mkOption {
          type = lib.types.str;
          default = if protocol == "naive" then "https" else protocol;
        };
        protocol = lib.mkOption {
          type = lib.types.enum [ "naive" ];
        };
        host = lib.mkOption {
          type = lib.types.str;
        };
        user = lib.mkOption {
          type = lib.types.str;
        };
        password = lib.mkOption {
          type = lib.types.str;
        };
      };
    }
  );
in
{
  options.networking.proxy.nodes = lib.mkOption {
    type = lib.types.attrsOf node;
    default = [ ];
  };
}
