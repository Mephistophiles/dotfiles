{ config, pkgs, lib, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      gnomeExtensions = super.gnomeExtensions // {
        paperwm = super.gnomeExtensions.paperwm.overrideDerivation (old: {
          version = "pre-41.0";
          src = super.fetchFromGitHub {
            owner = "PaperWM-community";
            repo = "PaperWM";
            rev = "b66aaf13e8f4cdf0e2f9078fb3e75703535b822c";
            sha256 = "sha256-6AUUu63oWxRw9Wpxe0f7xvt7iilvQfhpAB8SYG4yP8Q=";
          };
          #patches = old.patches or [ ] ++ [
          #  (self.fetchpatch {
          #    name = "pr-22.patch";
          #    url =
          #      "https://patch-diff.githubusercontent.com/raw/PaperWM-community/PaperWM/pull/22.patch";
          #    sha256 = "sha256-X/WqlhD3vfaZWscJYhTO0noarwyb8/s0C+vtWqk9tXM=";
          #  })
          #];
        });
      };
    })

  ];

  environment.gnome.excludePackages = [
    pkgs.gnome.cheese
    pkgs.gnome-photos
    pkgs.gnome.gnome-music
    #   pkgs.epiphany
    #   pkgs.evince
    pkgs.gnome.totem
    #   pkgs.gnome.tali
    #   pkgs.gnome.iagno
    #   pkgs.gnome.hitori
    pkgs.gnome-tour
    #   pkgs.gnome.geary
  ];
  environment.systemPackages = with pkgs; [
    gnome.gpaste
    gnome3.adwaita-icon-theme
    gnomeExtensions.caffeine
    gnomeExtensions.paperwm
    gnomeExtensions.system-monitor
    gnomeExtensions.vertical-overview
    unstable.gnomeExtensions.cleaner-overview
  ];
}
