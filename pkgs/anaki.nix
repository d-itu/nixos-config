{
  fetchFromGitHub,
  rustPlatform,

  pname ? "anaki",
  buildFeatures ? [ ],
}:
rustPlatform.buildRustPackage rec {
  inherit pname;
  version = "0.1.0";
  src =
    fetchFromGitHub {
      owner = "Flutterando";
      repo = "anakiORM";
      rev = "139f28ae8f99e8adc2077518b42c9a5fcacda90f";
      hash = "sha256-xw9laasb+pB6o4AhCRAwbvZw5LYEsBQ2tj6Mig7EYts=";
    }
    + /rust;
  cargoLock.lockFile = "${src}/rust/Cargo.lock";
  inherit buildFeatures;
}
