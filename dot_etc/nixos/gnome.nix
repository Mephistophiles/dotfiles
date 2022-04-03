{ config, pkgs, lib, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };

  environment.gnome.excludePackages = [
    pkgs.gnome.cheese
    pkgs.gnome-photos
    #   pkgs.gnome.gnome-music
    #   pkgs.epiphany
    #   pkgs.evince
    #   pkgs.gnome.totem
    #   pkgs.gnome.tali
    #   pkgs.gnome.iagno
    #   pkgs.gnome.hitori
    #   pkgs.gnome-tour
    #   pkgs.gnome.geary
  ];
  environment.systemPackages = with pkgs; [ gnome3.adwaita-icon-theme ];
}
