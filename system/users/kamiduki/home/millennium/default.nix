{ pkgs, osConfig, ... }: {
  xdg = {
    configFile."millennium/config.json" = {
      force = true;
      text = builtins.toJSON {
        general = {
          checkForMillenniumUpdates = false;
          checkForPluginAndThemeUpdates = false;
        };
        misc = {
          hasShownWelcomeModal = true;
        };
        themes = {
          activeTheme = "Material-Theme";
          conditions = {
            Material-Theme = {
              "Font" = "Custom";
              "Hide Window Control Buttons" = "yes";
              "Color" = "Matugen";
            };
          };
        };
      };
    };
    dataFile."Steam/millennium/themes/Material-Theme".source =
      pkgs.millennium-material-theme.override {
        customFont = osConfig.fonts.default.ui.name;
      }
      + /share/Steam/millennium/themes/Material-Theme;
  };
}
