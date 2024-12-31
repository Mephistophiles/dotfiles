{ pkgs, ... }:

{
  services = {
    displayManager = {
      defaultSession = "none+awesome";
    };
    xserver = {
      displayManager = {
        gdm.enable = true;
        #sddm.enable = true;
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
    udev.extraRules = ''
      KERNEL=="card[0-9]*", SUBSYSTEM=="drm", ACTION=="change", RUN+="${pkgs.unstable.autorandr}/bin/autorandr --batch --change --default default"
    '';
  };
  environment.systemPackages = with pkgs; [ unstable.flameshot unstable.xidlehook unstable.i3lock ];
}
