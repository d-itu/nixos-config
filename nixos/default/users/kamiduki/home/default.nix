{
  pkgs,
  ...
}:
{
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
  home.shellAliases = {
    ls = "ls --color=tty";
    ll = "ls -lh";
    la = "ls -lha";
    py = "python";
  };
  programs = {
    git.settings.user.email = "kamiduki_0@outlook.com";

    direnv.enable = true;
    bun.enable = true;
    fish.enable = true;
    jujutsu.enable = true;
    gh.enable = true;
    kitty.enable = true;
    zathura.enable = true;
    btop.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    fastfetch.enable = true;
    pi-coding-agent.enable = true;
    spicetify.enable = true;
    millennium.enable = true;
    noctalia.enable = true;
    yazi.enable = true;
    zen-browser.enable = true;
  };

  wayland.windowManager.niri.enable = true;

  i18n.inputMethod.enable = true;
}
