{ pkgs, ... }:

{
  services = {
    libinput = { enable = true; };
    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        HandlePowerKey=suspend
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
