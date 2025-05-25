{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    devenv.url = "github:cachix/devenv";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      inherit (nixpkgs) lib;
      unfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "obsidian"
          "vscode"
        ];

      inherit (inputs) devenv;
      inherit (inputs) nixpkgs;
      inherit (inputs) nixpkgs-unstable;
      inherit (inputs) home-manager;
      system = "x86_64-linux";
      config = { };

      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfreePredicate = unfreePredicate;
        };
      };

      devenv-overlay = final: prev: {
        devenv = devenv.packages.${system}.devenv;
      };

      overlays = [ overlay-unstable devenv-overlay ];
      nixpkgs-overlay = {
        config.allowUnfreePredicate = unfreePredicate;
        inherit overlays;
      };
      mkSystem = system: modules: lib.nixosSystem {
        system = system;
        # Things in this set are passed to modules and accessible
        # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager

          ({ pkgs, ... }: {
            nixpkgs = nixpkgs-overlay;
            nix.extraOptions = "experimental-features = nix-command flakes";
            nix.settings.trusted-users = [ "root" "@wheel" ];
            nix.package = pkgs.nixVersions.stable;
            nix.registry.nixpkgs.flake = nixpkgs;
            nix.registry = {
              nixpkgs-unstable.flake = nixpkgs-unstable;
              devenv.flake = devenv;
            };
            home-manager.useGlobalPkgs = true;
          })
        ] ++ modules;
      };
    in
    {
      homeConfigurations = {
        mzhukov = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system config overlays; };
          modules = [
            ./home.nix
          ];
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      nixosConfigurations = {
        mzhukov-laptop = mkSystem "x86_64-linux" [
          ./hardware-configuration-mzhukov-laptop.nix
          ./configuration.nix
          ./modules/desktop.nix
          ./modules/desktop-awesomewm.nix
          ./modules/laptop-setup.nix
          ./modules/monitor-setup.nix
          ./modules/keyboard-setup.nix
        ];
        mzhukov-mini-pc = mkSystem "x86_64-linux" [
          ./hardware-configuration-mzhukov-mini-pc.nix
          ./configuration.nix
        ];
      };
    };
}
