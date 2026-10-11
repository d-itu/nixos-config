{
  pkgs,
  constants,
  config,
  osConfig,
  ...
}:
let
  wallpapers = "${config.home.homeDirectory}/Pictures/Wallpapers";
  wallpapers-dark = "${wallpapers}/dark";
  wallpapers-light = "${wallpapers}/light";

  nixWallpapers =
    dir: names:
    names
    |> map (
      name:
      let
        pkg = pkgs.nixos-artwork.wallpapers."${name}";
      in
      {
        name = "${dir}/${name}.png";
        value.source = "${pkg}/share/backgrounds/nixos/nix-wallpaper-${name}.png";
      }
    )
    |> builtins.listToAttrs;
  mkWallpapers =
    args:
    { }
    // (args.nixos.dark |> nixWallpapers wallpapers-dark)
    // (args.nixos.light |> nixWallpapers wallpapers-light);

  plugins = {
    clock = {
      id = "local/clock";
      name = "Paper Clock";
      version = "0.1.0";
      plugin_api = 32;
      icon = "clock";
      widget = [
        {
          id = "clock";
          entry = ./plugins/clock.luau;
        }
      ];
    };
    snowflake = {
      id = "local/snowflake";
      name = "Snowflake";
      version = "0.1.0";
      plugin_api = 32;
      icon = "snowflake";
      widget = [
        {
          id = "snowflake";
          entry = pkgs.writeText "widget.luau" ''
            function update()
              barWidget.setImage("${snowflake_out}", true, 20)
            end
          '';
        }
      ];
    };
  };

  uid = toString osConfig.users.users.${config.home.username}.uid;
  runtimeDir = "/run/user/${uid}";
  snowflake_out = "${runtimeDir}/snowflake.svg";
  tomlFormat = pkgs.formats.toml { };
in
{
  home.file =
    mkWallpapers {
      nixos.dark = [
        "dracula"
        "gear"
        "simple-dark-gray"
        "nineish-dark-gray"
      ];
      nixos.light = [
        "simple-light-gray"
        "nineish"
      ];
    }
    // pkgs.lib.mapAttrs' (name: manifest: {
      name = "${config.home.homeDirectory}/.local/share/noctalia/plugins/${name}/plugin.toml";
      value.source = tomlFormat.generate "plugin.toml" manifest;
    }) plugins;
  programs.noctalia = {
    enable = true;
    settings = {
      config_version = 13;

      plugins.enabled = plugins |> pkgs.lib.mapAttrsToList (name: _: "local/${name}");

      theme = {
        mode = "auto";
        source = "wallpaper";
        templates = {
          builtin_ids = [
            "btop"
            "gtk3"
            "gtk4"
            "qt"
          ];
          community_ids = [
            "fcitx5"
            "zathura"
            "steam"
          ];
          user.snowflake = {
            input_path = ./templates/snowflake.svg;
            output_path = snowflake_out;
          };
        };
      };

      notification.background_opacity = 0.32;

      shell = {
        font_family = constants.ui_font;
        niri_overview_type_to_launch_enabled = true;
        password_style = "random";
        launcher = {
          categories = false;
          providers.calculator.global = false;
        };
        panel = {
          borders = false;
          control_center_placement = "floating";
          wallpaper_placement = "floating";
          session_placement = "floating";
        };
        screen_corners = {
          enabled = true;
          size = 18;
        };
        popup_borders = false;
        polkit_agent = true;
        greeter_sync.auto_sync = true;
      };

      system.monitor = {
        disk_poll_seconds = 0;
        memory_poll_seconds = 3;
      };

      wallpaper = {
        directory_dark = wallpapers-dark;
        directory_light = wallpapers-light;
        automation = {
          enabled = true;
          interval_seconds = 16200;
        };
      };

      backdrop = {
        enabled = true;
        blur_intensity = 1.0;
        tint_intensity = 0.1;
      };

      widget = {
        "local/snowflake" = {
          type = "local/snowflake:snowflake";
          actions = {
            left = "panel-toggle wallpaper";
            right = "panel-toggle clipboard";
          };
        };
        workspaces = {
          active_pill_size = 3.0;
          pill_scale = 0.7;
          show_labels = false;
        };
        active_window.icon_size = 22;
        media = {
          art_size = 90;
          capsule = true;
          capsule_opacity = 0.91;
          hide_when_no_media = true;
          show_progress = true;
          title_scroll = "on_hover";
        };
        notifications.hide_when_no_unread = true;
        battery = {
          display_mode = "graphic";
          scale = 0.85;
          show_label = false;
        };
        privacy.hide_inactive = true;
        brightness.show_label = false;
        volume.show_label = false;
        "local/clock" = {
          type = "local/clock:clock";
          actions = {
            left = "panel-toggle control-center calendar";
            right = "panel-toggle control-center notifications";
          };
        };
      };

      bar.default = {
        start = [
          "local/snowflake"
          "workspaces"
          "active_window"
        ];
        center = [ "media" ];
        end = [
          "tray"
          "privacy"
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "battery"
          "local/clock"
          "notifications"
        ];
        background_opacity = 0.0;
        margin_ends = 0;
        radius = 0;
        shadow = false;
        thickness = 30;
      };

      dock = {
        enabled = true;
        smart_auto_hide = true;
        launcher_position = "start";
        background_opacity = 0.47;
        border_width = 0.5;
        margin_edge = 6;
        reserve_space = false;
        radius = 22;
        inactive_opacity = 1.0;
        inactive_scale = 1.0;
        magnification_scale = 1.7;
        shadow = false;
        show_dots = true;
        show_instance_count = false;
        pinned = [
          "org.gnome.Nautilus"
          "zen-twilight"
        ];
      };

      osd = {
        orientation = "vertical";
        position_vertical = "center_right";
      };

      audio.enable_overdrive = true;
      battery.warning_threshold = 30;
      location.auto_locate = true;

      lockscreen.blurred_desktop = true;
    };
  };
}
