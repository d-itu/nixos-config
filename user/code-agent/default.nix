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
  home.file.".pi/agent/extensions/pi-web-access".source =
    let
      src = pkgs.fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-web-access";
        rev = "d47dc040552505e3b135d0136a0b15eaf4bdba52";
        hash = "sha256-rO7rj3RVS/79cUpWUZCXktaxJbjLO4QDPezRTn+H120=";
      };
      package = builtins.readFile "${src}/package.json" |> builtins.fromJSON;
    in
    pkgs.buildNpmPackage {
      pname = package.name;
      version = package.version;
      inherit src;
      npmDepsHash = "sha256-AuyRQCMcdPzkttqel4xUr0/lW+YkDGLufas45WMLZcg=";
    }
    + "/lib/node_modules/pi-web-access";
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
      };
    };
  };
}
