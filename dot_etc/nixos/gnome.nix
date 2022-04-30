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
          version = "pre-42.0";
          src = super.fetchFromGitHub {
            owner = "ccope";
            repo = "PaperWM";
            rev = "5ff631c216e9b43556bab369b0f5f984ea878ab0";
            sha256 = "sha256-Sn/04lTaeOD6yWHQn/+XXcfm3C+kaMngjiYf/Hy+QX8=";
          };
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
