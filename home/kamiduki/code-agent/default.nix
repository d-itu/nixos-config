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

  fetchBunDeps =
    {
      src,
      hash,
      workspace,
    }:

    pkgs.stdenvNoCC.mkDerivation {
      name = "bun-deps";
      inherit src;

      nativeBuildInputs = [ pkgs.bun ];

      outputHash = hash;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";

      dontConfigure = true;
      dontFixup = true;

      buildPhase = ''
        export BUN_INSTALL_CACHE_DIR=$TMPDIR/bun-cache
        bun install --frozen-lockfile --ignore-scripts --linker=hoisted --filter="${workspace}"
        rm "node_modules/${workspace}"
      '';
      installPhase = ''
        mv node_modules "$out"
      '';
    };

  nowaboua-pi-stuff = pkgs.fetchFromGitHub {
    owner = "IgorWarzocha";
    repo = "howaboua-pi-stuff";
    rev = "2e73770f9f74a22831e4813ad79ba0cbb7b92f6f";
    hash = "sha256-0XDSUFphUYF1Y+2KirtsZLQTtdNWco82Zb9RTtQjG7M=";
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
  home.file.".pi/agent/extensions/pi-codex-conversion".source =
    let
      src = nowaboua-pi-stuff;
      package = builtins.readFile "${src}/packages/pi-codex-conversion/package.json" |> builtins.fromJSON;
      deps = fetchBunDeps {
        inherit src;
        workspace = package.name;
        hash = "sha256-h90p+vf5MQwnfhMkH3xrCe0A1BXkB022Ld078diQ5CU=";
      };
    in
    pkgs.stdenvNoCC.mkDerivation {
      pname = package.name;
      version = package.version;
      inherit src;
      nativeBuildInputs = with pkgs; [
        bun
        nodejs
        typescript
      ];
      buildPhase = ''
        cd packages/pi-codex-conversion
        cp -r "${deps}" node_modules
        substituteInPlace tsconfig.build.json --replace-fail '"declaration": true' '"declaration": false'
        ${package.scripts.build}
      '';
      installPhase = ''
        cp -rL . $out
      '';
      dontFixup = true;
    };
  home.file.".pi/agent/pi-codex-conversion.json".text = builtins.toJSON {
    prompt.heavySystemPromptOverwrite = true;
    tools.customRustBinariesDir =
      let
        src = "${nowaboua-pi-stuff}/packages/pi-codex-conversion/src/tools";
      in
      pkgs.rustToolchain.buildRustPackage {
        pname = "pi-codex-conversion-tools";
        version = "0.0.0";
        inherit src;

        cargoLock.lockFile = "${src}/Cargo.lock";
      }
      + "/bin";
    scope.additionalProviders = providers |> pkgs.lib.mapAttrsToList (name: _: name);
  };
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
