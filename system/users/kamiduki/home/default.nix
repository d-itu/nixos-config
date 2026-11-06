{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  imports = [
    ./noctalia
    ./code-agent
    ./millennium
    ./yazi
    ./niri
    ./neovim
  ];
  home = {
    packages = with pkgs; [
      sops

      brightnessctl
      python3
      luajit
      tree-sitter
      zip
      unzip
      tokei
      typst
      tombi
      nixfmt
      meson
      cmake
      pkg-config
      rustToolchain
      zig
      uv
      ruff
      drift-player

      # gui
      nautilus
      resources
      localsend
    ];
    sessionVariables = {
      MANPAGER = "nvim +Man!";
      NIXOS_OZONE_WL = 1;
    };
    stateVersion = "26.05";
  };
  home.shell.enableZshIntegration = true;
  home.shellAliases = {
    ls = "ls --color=tty";
    ll = "ls -lh";
    la = "ls -lha";
    py = "python";
  };
  home.pointerCursor = {
    enable = true;
    inherit (osConfig.cursor) name package size;

    gtk.enable = true;
    x11.enable = true;
  };
  xdg = {
    mimeApps = {
      enable = true;
    };
  };
  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3";
    };
    iconTheme =
      let
        variant = "dracula";
      in
      {
        package = pkgs.tela-icon-theme.overrideAttrs {
          installPhase = ''
            runHook preInstall

            patchShebangs install.sh

            cp src/scalable/apps/zen-browser.svg src/scalable/apps/zen-twilight.svg

            mkdir -p $out/share/icons
            ./install.sh -d $out/share/icons ${variant}
            jdupes -l -r $out/share/icons

            runHook postInstall
          '';
        };
        name = "Tela-${variant}";
      };
    font = osConfig.fonts.default.ui;
  };
  qt =
    let
      settings = {
        Appearance = {
          color_scheme_path = "${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf";
          custom_palette = true;
          icon_theme = config.gtk.iconTheme.name;
        };
        Fonts = with osConfig.fonts.default; {
          fixed = with mono; "\"${name},${toString size}\"";
          general = with ui; "\"${name},${toString size}\"";
        };
        Interface = {
          dialog_buttons_have_icons = 0;
        };
      };
    in
    {
      enable = true;
      platformTheme.name = "qtct";
      qt5ctSettings = settings;
      qt6ctSettings = settings;
    };
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":";
    };
    "org/gnome/desktop/privacy" = {
      remember-recent-files = false;
    };
  };
  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "Host github.com" = {
          Hostname = "ssh.github.com";
          Port = 443;
          User = "git";
        };
      };
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = config.home.username;
          email = "kamiduki_0@outlook.com";
        };
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = true;
        };
      };
    };
    direnv.enable = true;
    bun.enable = true;
    zsh = {
      enable = true;

      setOptions = lib.mkForce [
        "share_history"
        "inc_append_history"
        "auto_cd"
        "extended_glob"
        "hist_fcntl_lock"
        "hist_ignore_dups"
        "hist_ignore_space"
        "no_append_history"
        "no_extended_history"
        "no_hist_expire_dups_first"
        "no_hist_find_no_dups"
        "no_hist_ignore_all_dups"
        "no_hist_save_no_dups"
      ];
      completionInit = "autoload -Uz compinit; compinit";
      plugins = [
        {
          name = "zsh-autopair";
          src = pkgs.zsh-autopair;
          file = "share/zsh/zsh-autopair/autopair.zsh";
        }
      ];
      initContent = builtins.readFile ./zsh/init.zsh;
    };
    starship = {
      enable = true;
      enableFishIntegration = false;
      presets = [ "nerd-font-symbols" ];
      settings = {
        format = lib.concatStrings [
          "$status"
          "$cmd_duration"
          "$jobs"
          "$nix_shell"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_state"
        ];
        add_newline = false;

        git_branch = {
          format = "[$symbol$branch(:$remote_branch)]($style) ";
          style = "bright-purple bold";
          truncation_length = 16;
          only_attached = true;
        };
        git_commit = {
          format = "[ $hash$tag]($style) ";
          style = "bright-purple bold";
        };

        nix_shell.format = "[$symbol$state(\($name\))]($style) ";

        cmd_duration = {
          format = "[$duration]($style) ";
          show_milliseconds = true;
        };

        status = {
          disabled = false;
          format = "[$status]($style) ";
        };

        directory = {
          format = "[$read_only]($read_only_style)[$path]($style) ";
          style = "bright-blue bold";
          read_only = "󰌾 ";
          read_only_style = "bright-red";
        };
      };
    };
    fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./fish/interactive.fish;
    };
    jujutsu = {
      enable = true;
      settings = {
        user = config.programs.git.settings.user;
        ui = {
          default-command = [ "status" ];
        };
        aliases = {
          e = [ "edit" ];
        };
      };
    };
    gh = {
      enable = true;
    };
    kitty = {
      enable = true;
      font = {
        package = pkgs.nerd-fonts.victor-mono;
        name = "VictorMono Nerd Font";
        size = 15;
      };
      extraConfig = builtins.readFile ./kitty/kitty.conf;
    };
    zathura = {
      enable = true;
      options = {
        font = with osConfig.fonts.default.mono; "${name} ${toString size}";
        guioptions = "v";
        recolor-keephue = true;
        selection-clipboard = "clipboard";
        window-title-basename = true;
      };
      extraConfig = ''
        include noctaliarc
      '';
    };
    zen-browser = {
      enable = true;
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

              "zen.widget.linux.transparency" = true;
              "zen.theme.content-element-separation" = 0;
              "zen.tabs.show-new-tab-vertical" = false;
            };
      };

      globalExtensions = with pkgs.firefox-addons; [
        ublock-origin
        github-file-icons
        darkreader
        simple-translate
      ];

      profiles.default = {
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

    less = {
      enable = true;
      options = {
        mouse = true;
        emouse = "all";
        use-color = true;
        no-vbell = true;
        SILENT = true;
        RAW-CONTROL-CHARS = true;
      };
      config = ''
        #command
        h left-scroll
        l right-scroll
      '';
    };

    btop.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    fastfetch.enable = true;

    fzf = {
      enable = true;
    };

    imv = {
      enable = true;
      settings = { };
    };

    spicetify = {
      enable = true;
      enabledExtensions = with pkgs.spicetify.extensions; [
        adblockify
        hidePodcasts
      ];
      wayland = true;
    };
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-anthy
        fcitx5-hangul
      ];
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "pinyin";
          "Groups/0/Items/2".Name = "anthy";
          "Groups/0/Items/3".Name = "hangul";
        };
        globalOptions = {
          "Hotkey/TriggerKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/AltTriggerKeys" = {
            "0" = "Super+Shift_L";
          };
        };
        addons = {
          classicui.globalSection = {
            Font = with config.gtk.font; "${name} ${toString (size * 1.4)}";
            Theme = "noctalia";
          };
          pinyin.globalSection = {
            CloudPinyinEnabled = true;
          };
          cloudpinyin.globalSection = {
            Backend = "Baidu";
          };
          anthy.sections = {
            General = {
              CandidateLayout = "Horizontal";
              NTriggersToShowCandWin = 1;
            };
          };
          hangul.globalSection = {
            Keyboard = "Romaja";
          };
        };
      };
      waylandFrontend = true;
    };
  };

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    secrets = {
      "sops/age/keys.txt" = {
        sopsFile = ./secrets/age/sops/keys.txt;
        path = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        format = "binary";
      };
    };
  };

  home.file.".ssh/id_ed25519.pub".source = ./id_ed25519.pub;
}
