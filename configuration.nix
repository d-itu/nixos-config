{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./system/network
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = false;
  };
  time.timeZone = "Asia/Shanghai";

  defaultUser = "kamiduki";

  users.users."${config.defaultUser}" = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
    ];
    uid = 1000;
  };

  environment = {
    systemPackages = with pkgs; [
      gcc
      clang
      gnumake
    ];
    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
    shellAliases = lib.mkForce { };
    variables = {
      EDITOR = "nvim";
    };
  };

  services = {
    displayManager = {
      enable = true;
      sessionPackages = with pkgs; [ niri ];

      noctalia-greeter = with config; {
        enable = true;
        passwordlessSyncUsers = [ defaultUser ];
        settings = {
          appearance = {
            hide_logo = true;
          };
          cursor = with cursor; {
            theme = name;
            path = "${package}/share/icons";
            inherit size;
          };
          auth.allow_empty_password = true;
        };
      };
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    upower.enable = true;
    power-profiles-daemon.enable = true;
    printing = {
      enable = true;
      drivers = with pkgs; [
        epson-escpr
      ];
      extraConf = "DefaultAuthType None";
    };
    avahi.enable = true;

    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    gvfs.enable = true;
    devmon.enable = true;
    fprintd.enable = true;
  };

  programs = {
    nano.enable = false;

    dconf.enable = true;
    git.enable = true;

    zsh = {
      enable = true;
      enableGlobalCompInit = false;
      setOptions = [ ];
      enableLsColors = false;
      promptInit = "";
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -U fish_greeting
      '';
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      package = pkgs.millennium-steam;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    gamescope = {
      enable = true;
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      corefonts
      sf-pro
    ];
    default.ui = {
      name = "SF Pro";
      size = 11;
    };
  };

  cursor = {
    package = pkgs.qogir-cursors;
    name = "Qogir-cursors";
    size = 24;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    substituters = [ "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store" ];
  };

  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
  };

  security = {
    sudo = {
      wheelNeedsPassword = false;
      extraConfig = ''
        Defaults !env_reset
      '';
    };
    rtkit.enable = true;
  };

  sops = {
    age.keyFile = "/etc/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;
    secrets = {
      "proxy_node/user" = { };
      "proxy_node/password" = { };
      "proxy_node/host" = { };
    };
  };

  system.stateVersion = "26.05";
}
