{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wl-send-key = {
      url = "github:d-itu/wl-send-key";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
    papervim.url = "github:d-itu/papervim";
    pi-web-access = {
      url = "github:nicobailon/pi-web-access?rev=d47dc040552505e3b135d0136a0b15eaf4bdba52";
      flake = false;
    };
    pi-apply-patch = {
      url = "github:code-yeongyu/pi-apply-patch";
      flake = false;
    };
    millennium-material-theme = {
      url = "github:kuska1/Material-Theme";
      flake = false;
    };
    sometimes = {
      url = "github:d-itu/sometimes";
      flake = false;
    };
    drift = {
      url = "github:socatlolmeow/drift";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      apple-fonts,
      millennium,
      rust-overlay,
      firefox-addons,
      spicetify-nix,
      wl-send-key,
      zen-browser,
      papervim,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
    in
    {
      packages.x86_64-linux =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        in
        builtins.readDir ./pkgs
        |> lib.mapAttrs' (
          pkg: _:
          let
            name = lib.removeSuffix ".nix" pkg;
          in
          {
            inherit name;
            value = pkgs.callPackage ./pkgs/${pkg} (
              if inputs |> lib.hasAttr name then { src = inputs."${name}"; } else { }
            );
          }
        );
      overlays.default =
        prev: final:
        let
          localPackages = self.packages.${prev.stdenv.hostPlatform.system};
          rustToolchain = prev.rust-bin.selectLatestNightlyWith (
            toolchain:
            toolchain.default.override {
              extensions = [
                "rust-src"
                "rust-analyzer"
              ];
            }
          );
          rustPlatform = prev.makeRustPlatform {
            cargo = rustToolchain;
            rustc = rustToolchain;
          };
          rustAttrs =
            attrs:
            let
              appDeps = rustPlatform.importCargoLock (
                attrs.cargoLock or { lockFile = "${attrs.src}/Cargo.lock"; }
              );
              stdDeps = rustPlatform.importCargoLock {
                lockFile = "${rustToolchain}/lib/rustlib/src/rust/library/Cargo.lock";
              };
            in
            {
              doCheck = false;
              cargoDeps = prev.runCommand "cargo-vendor-dir" { } ''
                mkdir -p "$out"
                cp -rs ${appDeps}/. "$out"
                for crate in ${stdDeps}/*/; do
                  ln -sfn "$crate" "$out/$(basename "$crate")"
                done
              '';
              CARGO_PROFILE_RELEASE_LTO = "fat";
              CARGO_PROFILE_RELEASE_CODEGEN_UNITS = 1;
              CARGO_PROFILE_RELEASE_PANIC = "abort";
              RUSTFLAGS = [
                "-Zshare-generics=y"
                "-Zunstable-options"
                "-Cpanic=immediate-abort"
              ];
              cargoBuildFlags = [
                "-Zbuild-std=core,std,alloc,panic_abort"
                "-Zbuild-std-features="
              ];
            };
          rustPkg = pkg: (pkg.override { inherit rustPlatform; }).overrideAttrs rustAttrs;
        in
        {
          spicetify = spicetify-nix.legacyPackages.${prev.stdenv.hostPlatform.system};
          wl-send-key = wl-send-key.packages.${prev.stdenv.hostPlatform.system}.default;
          inherit rustToolchain;
          sometimes = rustPkg localPackages.sometimes;
          lua-format = rustPkg final.lua-format;
          blink-cmp-fuzzy = rustPkg final.blink-cmp-fuzzy;
          drift-player = localPackages.drift;
          inherit (localPackages) qogir-cursors millennium-material-theme;
          piPlugins = {
            inherit (localPackages) pi-web-access pi-apply-patch;
          };
        };
      nixosModules = {
        default = {
          imports = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            self.nixosModules.system
            {
              nixpkgs.overlays = [
                apple-fonts.overlays.default
                millennium.overlays.default
                rust-overlay.overlays.default
                firefox-addons.overlays.default
                papervim.overlays.default
                self.overlays.default
              ];
              home-manager.sharedModules = [
                zen-browser.homeModules.twilight
                spicetify-nix.homeManagerModules.spicetify
                sops-nix.homeManagerModules.sops
              ];
            }
          ];
        };
        system = import ./system;
      };
      nixosConfigurations =
        builtins.readDir ./hosts
        |> builtins.mapAttrs (
          host: _:
          lib.nixosSystem {
            modules = [
              self.nixosModules.default
              { networking.hostName = host; }
              ./hosts/${host}
            ];
          }
        );
    };
}
