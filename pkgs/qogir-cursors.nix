{ stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation {
  pname = "qogir-cursors";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "Qogir-icon-theme";
    rev = "c633057ba0d27a504b3255144071c9691ed0264a";
    hash = "sha256-VJHhyKk1f/25CNkqNM7+WQqQRdqBNgWD3XrJ+whOcd0=";
  };

  installPhase = ''
    mkdir -p $out/share/icons
    cp -r src/cursors/dist $out/share/icons/Qogir-cursors
    cp -r src/cursors/dist-Dark $out/share/icons/Qogir-white-cursors
  '';
}
