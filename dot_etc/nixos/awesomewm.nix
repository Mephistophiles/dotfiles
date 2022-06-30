{ pkgs, ... }:

{
  services = {
    xserver = {
      displayManager = {
        sddm.enable = true;
        defaultSession = "none+awesome";
      };
      windowManager.awesome = {
        enable = true;
        luaModules = with pkgs.luaPackages; [
          luafilesystem
          luaposix
          vicious
        ];
      };
    };
  };
  environment.systemPackages = with pkgs; [ unstable.flameshot unstable.xidlehook unstable.i3lock ];
}
