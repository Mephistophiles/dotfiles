# https://www.tweag.io/blog/2020-07-31-nixos-flakes/

# To switch from channels to flakes execute:
# cd /etc/nixos
# sudo wget -O flake.nix https://gist.githubusercontent.com/misuzu/80af74212ba76d03f6a7a6f2e8ae1620/raw/flake.nix
# sudo sed -i "s/myhost/$(hostname)/g" flake.nix
# sudo git init
# sudo git add . # won't work without this
# nix run nixpkgs.nixFlakes -c sudo nix --experimental-features 'flakes nix-command' build .#nixosConfigurations.$(hostname).config.system.build.toplevel
# sudo ./result/bin/switch-to-configuration switch

# Now nixos-rebuild can use flakes:
# sudo nixos-rebuild switch --flake /etc/nixos

# To update flake.lock run:
# sudo nix flake update --commit-lock-file /etc/nixos

{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    devenv.url = "github:cachix/devenv";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      inherit (nixpkgs) lib;
      unfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # "displaylink"
          # "clion"
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

      overlays = [ overlay-unstable devenv-overlay inputs.neovim-nightly-overlay.overlay ];
      nixpkgs-overlay = {
        config.allowUnfreePredicate = unfreePredicate;
        inherit overlays;
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

      nixosConfigurations.mzhukov-laptop = lib.nixosSystem {
        system = "x86_64-linux";
        # Things in this set are passed to modules and accessible
        # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager

          ({ pkgs, ... }: {
            nixpkgs = nixpkgs-overlay;
            nix.extraOptions = "experimental-features = nix-command flakes";
            nix.settings.trusted-users = [ "root" "@wheel" ];
            nix.package = pkgs.nixFlakes;
            nix.registry.nixpkgs.flake = nixpkgs;
            nix.registry = {
              nixpkgs-unstable.flake = nixpkgs-unstable;
              devenv.flake = devenv;
            };
            home-manager.useGlobalPkgs = true;
          })

          ./configuration.nix
        ];
      };
    };
}
