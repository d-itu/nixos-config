{
  stdenvNoCC,
  nodejs,
  pnpm,
  pnpmConfigHook,
  pnpmBuildHook,
  fetchPnpmDeps,
  src,
}:
let
  package = builtins.readFile "${src}/package.json" |> builtins.fromJSON;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = package.name;
  version = package.version;
  inherit src;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 5;
    hash = "sha256-w/2aV2i9NT6+bhr8nrfSugzdtJOkdTg0QwiM+puKaj8=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    pnpmBuildHook
  ];

  installPhase = ''
    runHook preInstall

    pnpm install --offline --prod --frozen-lockfile

    package=$out/lib/node_modules/${finalAttrs.pname}
    mkdir -p $package
    cp -r . $package

    runHook postInstall
  '';
})
