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

  outputs = { nixpkgs, home-manager, ... } @ inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.x230 = nixpkgs.lib.nixosSystem {
      inherit system;
      # TODO: https://github.com/mattywillo/linuxcnc-nix
      modules = [
        ./system/configuration.nix
        ./system/disko_partition.nix
      ];
    };

    homeConfigurations.markus = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [ ./home-manager/home.nix ];
      extraSpecialArgs = {
        inherit inputs;
      };
    };
  };

}
