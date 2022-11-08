{ pkgs, ... }:

{
  services = {
    xserver = {
      displayManager = {
        lightdm = {
          enable = true;
          extraSeatDefaults = ''
            display-setup-script=${pkgs.writeShellScript "autorandr-test" ''
              ${pkgs.unstable.autorandr}/bin/autorandr --batch --change --default default
            ''}
          '';
        };
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
    udev.extraRules = ''
      KERNEL=="card[0-9]*", SUBSYSTEM=="drm", ACTION=="change", RUN+="${pkgs.unstable.autorandr}/bin/autorandr --batch --change --default default"
    '';
  };
  environment.systemPackages = with pkgs; [ unstable.flameshot unstable.xidlehook unstable.i3lock ];
}
