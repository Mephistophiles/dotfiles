{ config, pkgs, lib, ... }:

{
  services = {
    xserver = {
      # displayManager = {
      #   gdm = {
      #     enable = true;
      #     autoSuspend = false;
      #   };
      #   defaultSession = "none+i3";
      # };
      # windowManager.i3 = {
      #   enable = true;
      #   package = pkgs.i3-gaps;
      #   extraPackages = with pkgs; [
      #     autotiling
      #     i3lock
      #     xautolock
      #     xbindkeys
      #   ];
      # };

      displayManager = {
        sddm.enable = true;
        defaultSession = "none+awesome";
      };
      windowManager.awesome = {
        enable = true;
        luaModules = with pkgs.luaPackages; [
          luarocks # is the package manager for Lua modules
          luadbi-mysql # Database abstraction layer
        ];
      };
    };
  };
  environment.systemPackages = with pkgs; [ unstable.flameshot ];
}
