{
  stdenvNoCC,
}:
{
  src,
  pname,
  version ? "unstable",
}:
stdenvNoCC.mkDerivation {
  inherit src pname version;

  installPhase = ''
    runHook preInstall

    plugins=$out/share/noctalia/plugins
    mkdir -p $plugins
    cp -r . $plugins/${pname}

    runHook postInstall
  '';
}
