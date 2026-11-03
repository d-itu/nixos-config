{ src, buildNpmPackage }:
let
  package = builtins.readFile "${src}/package.json" |> builtins.fromJSON;
in
buildNpmPackage {
  pname = package.name;
  version = package.version;
  inherit src;
  dontNpmBuild = true;
  npmDepsHash = "sha256-IulD/ivK+UDN3tGVAXVC6XbqVrtK8z/zOsJtCKDOVyc=";
}
