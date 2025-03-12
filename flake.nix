{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # linuxcnc-nix = {
    #   url = "github:mattywillo/linuxcnc-nix";
    # };

    disko = {
      url = github:nix-community/disko;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, disko, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
          "lightburn"
        ];
      };
    };
  in {
    nixosConfigurations.x230 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs // { pkgs = pkgs; };
      # TODO: https://github.com/mattywillo/linuxcnc-nix
      modules = [
        disko.nixosModules.disko
        ./system/configuration.nix
        ./system/disk-config.nix
        # integrate home-manager in system configuration
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.markus = import ./home-manager/home.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        }
      ];
    };

    homeConfigurations.markus = home-manager.lib.homeManagerConfiguration {
      #pkgs = nixpkgs.legacyPackages.${system};
      inherit pkgs;
      modules = [ ./home-manager/home.nix ];
      extraSpecialArgs = {
        inherit inputs;
      };
    };
  };

}
