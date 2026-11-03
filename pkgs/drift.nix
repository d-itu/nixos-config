{
  lib,
  rustPlatform,
  makeWrapper,
  mpv,
  yt-dlp,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "drift";
  version = "1.4.0";

  inherit src;

  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [ makeWrapper ];

  doCheck = false;
  postInstall = ''
    wrapProgram $out/bin/drift --prefix PATH : ${
      lib.makeBinPath [
        mpv
        yt-dlp
      ]
    }
  '';
}
