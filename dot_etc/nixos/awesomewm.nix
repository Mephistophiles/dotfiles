{ config, pkgs, lib, ... }:

{
  services = {
    xserver = {
      displayManager = {
        sddm.enable = true;
        defaultSession = "none+awesome";
      };
      windowManager.awesome = {
        enable = true;
        luaModules = with pkgs.luaPackages; [ luafilesystem ];
      };
    };
  };
  programs.slock.enable = true;
  environment.systemPackages = with pkgs; [ unstable.flameshot ];
}
