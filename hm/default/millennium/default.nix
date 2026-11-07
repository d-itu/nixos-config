{ pkgs, osConfig, ... }: {
  programs.millennium = {
    config = {
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
    themes = {
      Material-Theme = pkgs.millennium-material-theme.override {
        customFont = osConfig.fonts.default.ui.name;
      };
    };
  };
}
