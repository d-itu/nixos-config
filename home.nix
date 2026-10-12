{
  inputs,
  pkgs,
  lib,
  constants,
  config,
  ...
}:
let
  snowflake = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
  rust = pkgs.rust-bin.selectLatestNightlyWith (
    toolchain:
    toolchain.default.override {
      extensions = [
        "rust-src"
        "rust-analyzer"
      ];
    }
  );
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight
    inputs.spicetify-nix.homeManagerModules.spicetify
    ./user/noctalia
    ./user/code-agent
    ./user/millennium
    ./user/yazi
    ./user/niri
  ];
  home = {
    inherit (constants) username;
    homeDirectory = "/home/${config.home.username}";
    packages = with pkgs; [
      sops

      brightnessctl
      python3
      zip
      unzip
      tokei
      typst
      tombi
      nixfmt
      meson
      cmake
      pkg-config
      rust

      # gui
      nautilus
      resources
      localsend

      # fonts
      sf-pro
      corefonts
    ];
    sessionVariables = {
      NVIM_APPNAME = "papervim";
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
  home.pointerCursor =
    let
      cursor = pkgs.callPackage ./utils/default-cursor.nix { };
    in
    {
      enable = true;
      inherit (cursor) name package size;

      gtk.enable = true;
      x11.enable = true;
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
    font = {
      name = constants.ui_font;
      size = constants.font_size;
    };
  };
  qt =
    let
      settings = {
        Appearance = {
          color_scheme_path = "${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf";
          custom_palette = true;
          icon_theme = config.gtk.iconTheme.name;
        };
        Fonts = {
          fixed = "\"Monospace,11\"";
          general = "\"${constants.ui_font},${toString constants.font_size}\"";
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
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ ];
      sansSerif = [ constants.ui_font ];
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
          name = constants.username;
          email = constants.email;
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
        user = {
          name = constants.username;
          inherit (constants) email;
        };
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
    neovim = {
      enable = true;
      extraPackages = with pkgs; [
        clang-tools
        fish-lsp
        lua-language-server
        nixd
        tinymist
        typescript-language-server
        vscode-json-languageserver
        yaml-language-server
      ];
    };
    neovide = {
      enable = true;
    };
    zathura = {
      enable = true;
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
        Preferences =
          builtins.mapAttrs
            (_: value: {
              Value = value;
              Status = "locked";
            })
            {
              "browser.aboutConfig.showWarning" = false;
              "dom.webgpu.enabled" = true;
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "devtools.chrome.enabled" = true;
            };
      };

      profiles.default = {
        settings = {
          "browser.tabs.hoverPreview.enabled" = true;
          "browser.translations.automaticallyPopup" = false;

          "zen.widget.linux.transparency" = true;
          "zen.theme.content-element-separation" = 0;
          "zen.tabs.show-new-tab-vertical" = false;

          "devtools.debugger.remote-enabled" = true;
        };

        extensions = {
          packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
            ublock-origin
            github-file-icons
            darkreader
            simple-translate
          ];
          settings = { };
        };

        search.force = true;
        search.engines = {
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

    spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        enable = true;
        enabledExtensions = with spicePkgs.extensions; [
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
            Font = "Noto Sans CJK SC Medium 16";
            UseDarkTheme = true;
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
}
