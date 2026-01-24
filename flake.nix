{
  description = "flake for nixos";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
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
