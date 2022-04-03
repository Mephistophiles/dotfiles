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
    nixpkgs.url = "nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager }:
    let
      unfreePredicate = pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [
          "clion"
          "slack"
          "vscode"
          "zoom"
        ];

      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfreePredicate = unfreePredicate;
        };
      };
      nixpkgs-overlay = {
        config.allowUnfreePredicate = unfreePredicate;
        overlays = [ overlay-unstable ];
      };
    in {
      homeConfigurations = {
        mzhukov = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/mzhukov";
          username = "mzhukov";
          configuration = { pkgs, config, ... }: {
            nixpkgs = nixpkgs-overlay;
            programs.home-manager.enable = true;
            imports = [ ./home.nix ];
          };
        };
      };

      nixosConfigurations.mzhukov-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Things in this set are passed to modules and accessible
        # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager

          ({ pkgs, ... }: {
            imports =
              (if (nixpkgs.lib.versionAtLeast nixpkgs.lib.version "21.10") then
                [
                  "${nixpkgs-unstable}/nixos/modules/services/networking/wg-quick.nix"
                ]
              else
                abort "remove this override");
            disabledModules = [ "services/networking/wg-quick.nix" ];
            nixpkgs = nixpkgs-overlay;
            nix.extraOptions = "experimental-features = nix-command flakes";
            nix.package = pkgs.nixFlakes;
            nix.registry.nixpkgs.flake = nixpkgs;
            nix.registry.nixpkgs-unstable.flake = nixpkgs-unstable;

            home-manager.useGlobalPkgs = true;
          })

          ./configuration.nix
        ];
      };
    };
}
