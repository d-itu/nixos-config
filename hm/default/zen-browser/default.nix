{
  pkgs,
  ...
}:
{
  programs.zen-browser = {
    setAsDefaultBrowser = true;

    policies = {
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      NoDefaultBookmarks = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      ExtensionUpdate = false;
      Preferences =
        builtins.mapAttrs
          (_: value: {
            Value = value;
            Status = "locked";
          })
          {
            "browser.aboutConfig.showWarning" = false;
            "browser.tabs.hoverPreview.enabled" = true;
            "browser.translations.automaticallyPopup" = false;

            "extensions.update.autoUpdateDefault" = false;
            "extensions.systemAddon.update.enabled" = false;

            "dom.webgpu.enabled" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            "devtools.chrome.enabled" = true;
            "devtools.debugger.remote-enabled" = true;
          };
    };

    globalExtensions =
      with pkgs.firefox-addons;
      [
        ublock-origin
        github-file-icons
        darkreader
        simple-translate
        vimium
      ]
      |> map (package: {
        inherit package;
        settings = {
          private_browsing = true;
        };
      });

    profiles.default = {
      settings = {
        "zen.widget.linux.transparency" = true;
        "zen.theme.content-element-separation" = 0;
        "zen.tabs.show-newtab-vertical" = false;
      };
      extensions = {
        force = true;
        settings = with pkgs.firefox-addons; {
          "${simple-translate.addonId}".settings = {
            Settings = {
              targetLang = "zh-CN";
            };
          };
          "${darkreader.addonId}".settings = {
            fetchNews = false;
            automation.enabled = true;
          };
        };
      };
      search.force = true;
      search.engines =
        let
          snowflake = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        in
        {
          "GitHub" = {
            urls = [ { template = "https://github.com/search?q={searchTerms}&type=repositories"; } ];
            icon = "https://github.githubassets.com/favicons/favicon.svg";
            definedAliases = [ "github" ];
          };
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages?type=packages&channel=unstable&query={searchTerms}";
              }
            ];
            icon = snowflake;
            definedAliases = [ "nixpkgs" ];
          };
          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
              }
            ];
            icon = snowflake;
            definedAliases = [ "nixoptions" ];
          };
          "Home Manager Options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com?query={searchTerms}&release=master";
              }
            ];
            icon = snowflake;
            definedAliases = [ "homemanager" ];
          };
        };
    };
  };
}
