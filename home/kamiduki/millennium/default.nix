{ pkgs, ... }: {
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
              "Hide Window Control Buttons" = "yes";
              "Color" = "Matugen";
            };
          };
        };
      };
    };
    dataFile."Steam/millennium/themes/Material-Theme".source = pkgs.millennium-material-theme;
  };
}
