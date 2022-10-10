{ pkgs, ... }:

{
  services = {
    xserver = {
      displayManager = {
        lightdm = {
          enable = true;
          extraSeatDefaults = ''
            display-setup-script=${pkgs.writeShellScript "autorandr-test" ''
              ${pkgs.unstable.autorandr}/bin/autorandr -c
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
  };
  environment.systemPackages = with pkgs; [ unstable.flameshot unstable.xidlehook unstable.i3lock ];
}
