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
        font = pkgs.lib.hm.types.fontType;
      in
      {
        ui = lib.mkOption { type = font; };
        serif = lib.mkOption { type = font; };
        mono = lib.mkOption { type = font; };
        terminal = lib.mkOption { type = font; };
        code = lib.mkOption { type = font; };
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
      default =
        let
          mono = {
            name = lib.mkDefault config.fonts.default.mono.name;
            size = lib.mkDefault config.fonts.default.mono.size;
            package = lib.mkDefault config.fonts.default.mono.package;
          };
        in
        {
          terminal = mono;
          code = mono;
        };
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
