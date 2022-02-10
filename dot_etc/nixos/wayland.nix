{ config, pkgs, lib, ... }:

{
  services = {
    xserver = {
      displayManager = {
        gdm = {
          enable = true;
          autoSuspend = false;
        };
        defaultSession = "sway";
      };
    };
  };
  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        clipman
        autotiling
        sway-contrib.grimshot
        swayidle
        swaylock
        wl-clipboard
      ];
    };
  };
}
