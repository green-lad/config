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

    sops-nix = {
      url = github:mic92/sops-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops_secrets = {
      url = "git+ssh://git@github.com/green-lad/sops_secrets.git?shallow=1";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, disko, sops-nix, ... } @ inputs:
  let
    system = "x86_64-linux";
    user = "markus";
    # hostname = builtins.getEnv "HOST";
    hostname = "x230";
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
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs // { pkgs = pkgs; } // { user = user; } // { hostname = hostname; };
        # TODO: https://github.com/mattywillo/linuxcnc-nix
        modules = [
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./system/configuration.nix
          ./system/sops.nix
          ./disk-config.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users = { "${user}" = import ./home-manager/home.nix; };
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit user;
              inherit hostname;
            };
          }
        ];
      };
    };

    homeConfigurations = {
      "${user}" = home-manager.lib.homeManagerConfiguration {
        #pkgs = nixpkgs.legacyPackages.${system};
        inherit pkgs;
        modules = [
	  ./home-manager/home.nix
	];
        extraSpecialArgs = {
          inherit inputs;
          inherit user;
          inherit hostname;
        };
      };
    };
  };

}
