{ pkgs, ... }: {
  package = pkgs.callPackage ../pkgs/qogir-cursors.nix { };
  name = "Qogir-cursors";
  size = 24;
}
