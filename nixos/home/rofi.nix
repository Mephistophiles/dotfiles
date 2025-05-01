{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.rofi = {
    enable = true;

    location = "center";
    theme = "Arc-Dark";

    plugins = [pkgs.rofi-calc];

    extraConfig = {
      sort = true;
      sorting-method = "fzf";
    };
  };
}
