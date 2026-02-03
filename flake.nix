{
  description = "flake for nixos";

  inputs = {
    # default (unstable)
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # optional alternative (stable)
    nixpkgs-stable = {
      url = "github:NixOS/nixpkgs?ref=release-25.11";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager }:
    let
      overlays = [
        (import ./overlays/ps4-pkg-tools.nix)
        (import ./overlays/zed-no-tests.nix)
        # (import ./overlays/webcord-npm-fix.nix)
      ];
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./hosts/desktop/configuration.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = overlays;
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Expose stable as `stable` for Home Manager modules.
              #
              # Usage inside HM modules:
              #   { pkgs, stable, ... }:
              #   { home.packages = [ stable.zed-editor ]; }
              home-manager.extraSpecialArgs = {
                stable = import nixpkgs-stable {
                  system = "x86_64-linux";
                  overlays = overlays;
                  config.allowUnfree = true;
                };
              };

              home-manager.users.hbarn = {
                imports = [
                  ./home/hbarn/home.nix
                ];
              };
            }
          ];
        };
      };
    };
}
