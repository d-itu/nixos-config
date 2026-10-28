{ rustPlatform, src }:
rustPlatform.buildRustPackage {
  pname = "sometimes";
  version = "0.1.0";

  inherit src;

  cargoLock.lockFile = src + /Cargo.lock;
}
