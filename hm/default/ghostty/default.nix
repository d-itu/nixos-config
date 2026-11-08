{
  osConfig,
  ...
}:
{
  programs.ghostty = {
    settings =
      let
        font = osConfig.fonts.default.terminal;
      in
      {
        font-size = font.size;
        font-family = font.name;

        adjust-cell-width = -1;
        adjust-cursor-thickness = 1;

        cursor-style = "block";
        cursor-style-blink = false;

        custom-shader = builtins.path { path = ./shaders/cursor.frag; };

        mouse-scroll-multiplier = 1.0;

        confirm-close-surface = false;
        gtk-single-instance = true;
        quit-after-last-window-closed-delay = "15m";

        keybind = [
          "super+enter=new_window"
          "ctrl+n=new_window"
          "ctrl+shift+alt+j=new_window"
          "ctrl+enter=unbind"
          "ctrl+tab=unbind"
          "ctrl+shift+enter=unbind"
        ];

        window-padding-x = 0;
        window-padding-y = 0;

        gtk-custom-css = builtins.path { path = ./style.css; };

        shell-integration-features = true;
      };
  };
}
