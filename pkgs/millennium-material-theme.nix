{
  lib,
  stdenvNoCC,
  src,

  customFont ? null,
}:
let
  installCustomFont =
    if customFont != null then
      ''
        cat << EOF > $target/customFont.css
        * {
          font-family: "${customFont}", sans-serif !important;
        }
        EOF
      ''
    else
      "";
in
stdenvNoCC.mkDerivation {
  pname = "millennium-material-theme";
  version = "unstable";

  src = lib.cleanSource src;

  installPhase = ''
    runHook preInstall

    target=$out/share/Steam/millennium/themes/Material-Theme
    mkdir -p $target
    cp -r . $target
    ${installCustomFont}

    runHook postInstall
  '';
}
