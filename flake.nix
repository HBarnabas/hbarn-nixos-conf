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
    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, mango }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit mango;
        };
        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager
          mango.nixosModules.mango
          {
       	    home-manager.useGlobalPkgs = true;
       	    home-manager.useUserPackages = true;
       	    home-manager.users.hbarn = {
              imports = [
                ./home/hbarn/home.nix
                mango.hmModules.mango
              ];
            };
          }
        ];
      };
    };
  };
}
