{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    fonts.default =
      let
        font = {
          name = lib.mkOption {
            type = lib.types.str;
          };
          size = lib.mkOption {
            type = lib.types.number;
          };
          package = lib.mkOption {
            type = lib.types.package;
          };
        };
      in
      {
        ui = font;
        mono = font;
        serif = font;
      };
    defaultUser = lib.mkOption {
      type = lib.types.str;
    };
    cursor = {
      package = lib.mkOption {
        type = lib.types.package;
      };
      name = lib.mkOption {
        type = lib.types.str;
      };
      size = lib.mkOption {
        type = lib.types.int;
      };
    };
  };
  config = {
    fonts = {
      packages = pkgs.lib.mapAttrsToList (name: value: value.package) config.fonts.default;
      fontconfig = {
        defaultFonts = with config.fonts.default; {
          monospace = [ mono.name ];
          sansSerif = [ ui.name ];
          serif = [ serif.name ];
        };
      };
    };
  };
}
