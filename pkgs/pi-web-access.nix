{ src, buildNpmPackage }:
let
  package = builtins.readFile "${src}/package.json" |> builtins.fromJSON;
in
buildNpmPackage {
  pname = package.name;
  version = package.version;
  inherit src;
  npmDepsHash = "sha256-AuyRQCMcdPzkttqel4xUr0/lW+YkDGLufas45WMLZcg=";
}
