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
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nur.url = github:nix-community/NUR;
    # nixpkgs-trunk.url = "nixpkgs/master";

    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      inherit (nixpkgs) lib;
      unfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "obsidian"
          "saleae-logic"
          # "clion"
          "rescuetime"
          "vscode"
        ];

      nixpkgs = inputs.nixpkgs;
      nixpkgs-unstable = inputs.nixpkgs-unstable;
      # nixpkgs-trunk = inputs.nixpkgs-trunk;
      home-manager = inputs.home-manager;
      nur = inputs.nur;

      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfreePredicate = unfreePredicate;
        };
        # trunk = import nixpkgs-trunk {
        #   system = "x86_64-linux";
        #   config.allowUnfreePredicate = unfreePredicate;
        # };
      };
      nixpkgs-overlay = {
        config.allowUnfreePredicate = unfreePredicate;
        overlays = [ overlay-unstable ];
      };
    in
    {
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

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      nixosConfigurations.mzhukov-laptop = lib.nixosSystem {
        system = "x86_64-linux";
        # Things in this set are passed to modules and accessible
        # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          nur.nixosModules.nur

          ({ pkgs, ... }: {
            nixpkgs = nixpkgs-overlay;
            nix.extraOptions = "experimental-features = nix-command flakes";
            nix.package = pkgs.nixFlakes;
            nix.registry.nixpkgs.flake = nixpkgs;
            nix.registry.nixpkgs-unstable.flake = nixpkgs-unstable;
            # nix.registry.nixpkgs-trunk.flake = nixpkgs-trunk;
            home-manager.useGlobalPkgs = true;
          })

          ./configuration.nix
        ];
      };
    };
}
