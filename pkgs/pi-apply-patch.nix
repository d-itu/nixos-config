{ fetchFromGitHub, buildNpmPackage }:
let
  src = fetchFromGitHub {
    owner = "d3ara1n";
    repo = "pi-extensions";
    rev = "87a0936f5e45189b143ba59f31a27d874188f29a";
    hash = "sha256-v8UmFiyptHUp2n8cptgPPCI2G9Aq+08g7ACA0PCLFTk=";
  };
  workspace = "packages/pi-apply-patch";
  package = builtins.readFile "${src}/${workspace}/package.json" |> builtins.fromJSON;
in
buildNpmPackage rec {
  pname = "pi-apply-patch";
  version = package.version;
  inherit src;
  dontNpmBuild = true;
  npmDepsHash = "sha256-5GIYftLBOboLlTC5DF8oCHPku0Yw6fSZdyiSWEEtX6A=";
  npmWorkspace = workspace;
  postInstall = ''
    packageRoot="$out/lib/node_modules/pi-extensions-monorepo"
    find "$packageRoot/node_modules" -xtype l -delete

    mkdir -p "$out/lib/node_modules"
    mv "$packageRoot" "$out/lib/node_modules/${pname}"
  '';
}
