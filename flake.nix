{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixvim.url = "github:green-lad/nixvim-config";

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
      url = "git+ssh://git@github.com/green-lad/sops_secrets?shallow=1";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, disko, sops-nix, ... } @ inputs:
  let
    pkgsWithUnfree = unfreePackages: system:
    (
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) unfreePackages;
        };
      }
    );

    systems = {
      x230 = {
        hostname = "x230";
        system = "x86_64-linux";
        users = [ "markus" ];
        unfreePackages = [
          "lightburn"
        ];
      };
      nuc = {
        hostname = "nuc";
        system = "x86_64-linux";
        users = [ "markus" ];
        unfreePackages = [
          "lightburn"
          "zoom-us"
          "steam"
        ];
      };
    };

  in {
    nixosConfigurations = builtins.mapAttrs (n: v: nixpkgs.lib.nixosSystem {
      system = v.system;
      specialArgs = inputs // { pkgs = pkgsWithUnfree v.unfreePackages v.system; } // { user = builtins.head v.users; } // { hostname = v.hostname; };
      modules = [
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        ./nixos/configuration.nix
        ./nixos/sops.nix
        ./disk-config.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users = { "${builtins.head v.users}" = import ./home-manager/home.nix; };
          home-manager.extraSpecialArgs = {
            inherit inputs;
            user = builtins.head v.users;
            hostname = v.hostname;
            system = v.system;
          };
        }
      ];
    }) systems;

    homeConfigurations = builtins.mapAttrs (n: v: home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsWithUnfree v.unfreePackages v.system;
        modules = [
          ./home-manager/home.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          user = builtins.head v.users;
          hostname = v.hostname;
          system = v.system;
        };
      }) systems;
  };
}
