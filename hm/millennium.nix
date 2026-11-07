{
  lib,
  config,
  ...
}:
{
  options = {
    programs.millennium = {
      enable = lib.mkEnableOption "manage themes/plugins for the desktop Steam Client";
      config = lib.mkOption {
        type = lib.types.json;
      };
      themes = lib.mkOption {
        type = lib.types.attrsOf lib.types.package;
        default = [ ];
      };
    };
  };
  config =
    let
      cfg = config.programs.millennium;
    in
    lib.mkIf cfg.enable {
      xdg = {
        configFile."millennium/config.json" = lib.mkIf (cfg.config != null) {
          force = true;
          text = builtins.toJSON cfg.config;
        };
        dataFile =
          cfg.themes
          |> lib.mapAttrs' (
            name: value: {
              name = "Steam/millennium/themes/${name}";
              value.source = value + /share/Steam/millennium/themes/Material-Theme;
            }
          );
      };
    };
}
