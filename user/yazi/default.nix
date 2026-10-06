{
  pkgs,
  ...
}:
{
  programs.yazi = {
    enable = true;
    plugins = with pkgs.yaziPlugins; {
      git = {
        package = git;
        setup = true;
      };
      chmod = {
        package = chmod;
      };
      compress = {
        package = compress;
      };
    };
    settings = {
      plugin = {
        prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
          }
        ];
      };
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "<Backspace>";
          run = "back";
          desc = "Back to previous directory";
        }
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
        {
          on = [
            "c"
            "a"
            "a"
          ];
          run = "plugin compress";
          desc = "Archive selected files";
        }
        {
          on = [
            "c"
            "a"
            "p"
          ];
          run = "plugin compress -p";
          desc = "Archive selected files (password)";
        }
        {
          on = [
            "c"
            "a"
            "h"
          ];
          run = "plugin compress -ph";
          desc = "Archive selected files (password+header)";
        }
        {
          on = [
            "c"
            "a"
            "l"
          ];
          run = "plugin compress -l";
          desc = "Archive selected files (compression level)";
        }
        {
          on = [
            "c"
            "a"
            "u"
          ];
          run = "plugin compress -phl";
          desc = "Archive selected files (password+header+level)";
        }
      ];
    };
    theme =
      let
        empty = {
          open = "";
          close = "";
        };
        square = {
          open = "█";
          close = "█";
        };
      in
      {
        indicator = {
          padding = square;
        };
        tabs = {
          sep_inner = empty;
          sep_outer = empty;
        };
        status = {
          sep_left = empty;
          sep_right = empty;
        };
      };
  };
}
