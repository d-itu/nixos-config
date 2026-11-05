{ pkgs, ... }:
let
  context = ./AGENTS.md;
  providers = {
    opentech = {
      name = "Opentech";
      base_url = "https://api.opentech.top";
    };
    deemos_sub = {
      name = "Deemos Sub";
      base_url = "https://sub.deemos.dev/v1";
    };
  };
  default = {
    provider = "opentech";
    model = "gpt-6-sol";
  };
  plugins = with pkgs.piPlugins; [
    pi-web-access
    pi-apply-patch
  ];
in
{
  home.file =
    plugins
    |> map (plugin: {
      name = ".pi/agent/extensions/${plugin.pname}";
      value.source = plugin + "/lib/node_modules/${plugin.pname}";
    })
    |> builtins.listToAttrs;
  programs = {
    pi-coding-agent = {
      enable = true;
      extraPackages = with pkgs; [ wl-clipboard ];
      inherit context;
      models = {
        providers = builtins.mapAttrs (
          _:
          { name, base_url }:
          {
            inherit name;
            baseUrl = base_url;
            api = "openai-responses";
            models = [
              {
                id = "gpt-6-astra";
                reasoning = true;
              }
              {
                id = "gpt-6-sol";
                reasoning = true;
              }
            ];
          }
        ) providers;
      };
      settings = {
        defaultProvider = default.provider;
        defaultModel = default.model;

        showHardwareCursor = true;
      };
    };
  };
}
