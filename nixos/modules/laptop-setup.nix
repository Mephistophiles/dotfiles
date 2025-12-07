{ pkgs, ... }:

{
  services = {
    libinput = { enable = true; };
    logind = {
      settings = {
        Login = {
          HandleLidSwitch = "suspend-then-hibernate";
          HandleLidSwitchDocked = "ignore";
          HandleLidSwitchExternalPower = "suspend";
          HandlePowerKey = "suspend";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
