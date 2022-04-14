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
            owner = "paperwm";
            repo = "PaperWM";
            rev = "e9f714846b9eac8bdd5b33c3d33f1a9d2fbdecd4";
            sha256 = "0wdigmlw4nlm9i4vr24kvhpdbgc6381j6y9nrwgy82mygkcx55l1";
          };
          patches = old.patches ++ [ ./patches/paperwm-gnome-41.patch ];
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
