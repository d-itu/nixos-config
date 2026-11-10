{ pkgs, ... }:
let
  context = ./AGENTS.md;
  mkOpenaiModel = id: {
    inherit id;
    reasoning = true;
    input = [
      "text"
      "image"
    ];
  };
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
              (mkOpenaiModel "gpt-6-astra")
              (mkOpenaiModel "gpt-6-sol")
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
