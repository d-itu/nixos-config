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
    dataFile."Steam/millennium/themes/Material-Theme" = {
      source = pkgs.fetchFromGitHub {
        owner = "kuska1";
        repo = "Material-Theme";
        rev = "f91b4e9cbc5436f149e6b293391a9a96ab47fbe9";
        hash = "sha256-qPzo59NyKsmKkhupOf3n9X29p/Wbv7jaKDGaM23HTJo=";
      };
    };
  };
}
