{ config, pkgs, lib, ... }:

{
  boot = {
    kernelParams = [ "i915.force_probe=46d4" ];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
    ];
  };

  networking = {
    hostName = "mzhukov-mini-pc"; # Define your hostname.
  };
}
