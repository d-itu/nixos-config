{ pkgs, ... }: {
  wayland.windowManager.niri =
    let
      spawn-terminal-cmd = "spawn-terminal";
      spawn-terminal-pkg = pkgs.writeShellApplication {
        name = spawn-terminal-cmd;
        runtimeInputs = with pkgs; [
          jq
          slurp
          xdg-terminal-exec
          niri
          wl-send-key
        ];
        text = builtins.readFile ./spawn-terminal.sh;
      };
      spawn-terminal = "${spawn-terminal-pkg}/bin/${spawn-terminal-cmd}";
    in
    {
      settings = {
        include = builtins.path {
          path = ./config.kdl;
        };
        binds = {
          "Mod+Return" = {
            _props.repeat = false;
            spawn = [ spawn-terminal ];
          };
          "Mod+Shift+Return" = {
            _props.repeat = false;
            spawn = [ "${pkgs.xdg-terminal-exec}/bin/xdg-terminal-exec" ];
          };
        };
      };
    };
}
