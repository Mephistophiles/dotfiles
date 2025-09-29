{ pkgs, ... }:

{
  services = {
    displayManager = {
      defaultSession = "none+awesome";
      sddm.enable = true;
    };
    xserver = {
      enable = true;
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
  programs.i3lock.enable = true;
  security.pam.services.i3lock.enable = true;
  environment.systemPackages = with pkgs; [
    flameshot
    xidlehook
  ];
}
