{
  lib,
  stdenv,
  stdenvNoCC,
  buildDartApplication,
  anaki,

  src,
}:
let
  drivers = [
    "sqlite"
    "postgres"
    "mysql"
    "mssql"
    "redis"
    "mongodb"
  ];
  arch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x64";
  version =
    builtins.readFile "${src}/cockpit/pubspec.yaml"
    |> lib.splitString "\n"
    |> lib.findFirst (lib.hasPrefix "version: ") (throw "Cockpit version not found")
    |> lib.removePrefix "version: ";
  nativeDrivers = lib.genAttrs drivers (
    driver:
    anaki.override {
      pname = "anaki-${driver}";
      buildFeatures = [ driver ];
    }
  );
  sourceBuilders = lib.genAttrs (map (driver: "anaki_${driver}") drivers) (
    name:
    {
      src,
      version,
      ...
    }:
    let
      driver = lib.removePrefix "anaki_" name;
    in
    stdenvNoCC.mkDerivation {
      pname = name;
      inherit version src;
      passthru.packageRoot = ".";
      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        cp -r . "$out/"
        chmod -R u+w "$out"
        rm -rf "$out/native_libs"
        mkdir "$out/native_libs"
        cp ${nativeDrivers.${driver}}/lib/libanaki_native.so "$out/native_libs/libanaki_${driver}-linux-${arch}.so"
        runHook postInstall
      '';
    }
  );
in
buildDartApplication {
  pname = "cockpit_server";
  inherit version src;
  sourceRoot = "source/cockpit/packages/cockpit_server";
  autoPubspecLock = "${src}/cockpit/packages/cockpit_server/pubspec.lock";
  customSourceBuilders = sourceBuilders;

  buildPhase = ''
    runHook preBuild
    dart build cli -o build/server
    cc -shared -fPIC -O2 -DDART_SHARED_LIB \
      -o build/libcockpit_pty.so \
      ../../plugins/cockpit_pty/src/cockpit_pty.c \
      -I../../plugins/cockpit_pty/src -lpthread
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/lib"
    cp -r build/server/bundle/bin/. "$out/bin/"
    cp -r build/server/bundle/lib/. "$out/lib/"
    cp build/libcockpit_pty.so "$out/lib/"
    runHook postInstall
  '';
}
