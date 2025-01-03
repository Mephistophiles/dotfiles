{ config, pkgs, lib, ... }:

{
  boot = {
    initrd = { kernelModules = [ "amdgpu" ]; };
  };
  services = {
    xserver = {
      videoDrivers = [ "amdgpu" ];
    };
  };

  # environment.systemPackages = with pkgs; [ matebook-applet ];
  networking = {
    hostName = "mzhukov-laptop"; # Define your hostname.
  };
}
