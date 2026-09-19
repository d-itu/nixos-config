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
in
{
  programs = {
    pi-coding-agent = {
      enable = true;
      extraPackages = with pkgs; [
        nodejs
      ];
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

        packages = [
          "npm:pi-web-access"
        ];
      };
    };
  };
}
