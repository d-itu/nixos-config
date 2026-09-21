{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    daeuniverse.url = "github:daeuniverse/flake.nix";
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
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      home-manager,
      apple-fonts,
      sops-nix,
      daeuniverse,
      noctalia-greeter,
      ...
    }@inputs:
    let
      username = "kamiduki";
      constants = {
        inherit username;
        email = "kamiduki_0@outlook.com";

        ui_font = "SF Pro";
        font_size = 11;
      };
      specialArgs = {
        inherit inputs;
        inherit constants;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          daeuniverse.nixosModules.dae
          noctalia-greeter.nixosModules.default
          {
            nixpkgs.overlays = [
              apple-fonts.overlays.default
            ];
            home-manager = {
              extraSpecialArgs = specialArgs;
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${constants.username}" = import ./home.nix;
            };
          }
        ];
      };
    };
}
