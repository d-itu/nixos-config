{ rustPlatform, fetchFromGitHub }:
let
  src = fetchFromGitHub {
    owner = "d-itu";
    repo = "sometimes";
    rev = "2a5f73314944c69640d099893e06962746340095";
    hash = "sha256-bp/jp+1EJV16B4Ubb98Pi3lAzDN6ruebte0vQ3ZlYd8=";
  };
in
rustPlatform.buildRustPackage {
  pname = "sometimes";
  version = "0.1.0";

  inherit src;

  cargoLock.lockFile = src + /Cargo.lock;
}
