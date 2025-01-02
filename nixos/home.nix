# vim:expandtab ts=2 sw=2

{ config, pkgs, lib, ... }:

{
  imports = [
    ./variables.nix
    ./home/git.nix
    ./home/tmux.nix
  ];

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    go.enable = true;
    gpg.enable = true;
  };

  services = {
    opensnitch-ui.enable = true;
    gpg-agent = {
      enable = true;

      defaultCacheTtl = 86400;
      defaultCacheTtlSsh = 86400;
      maxCacheTtl = 86400;
      maxCacheTtlSsh = 86400;
      enableSshSupport = true;
      extraConfig = ''
        pinentry-program ${pkgs.pinentry-qt}/bin/pinentry
      '' + ''
        allow-loopback-pinentry
      '';
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mzhukov";
  home.homeDirectory = "/home/mzhukov";
  home.stateVersion = "24.11";

  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    ${pkgs.unstable.nvd}/bin/nvd diff $oldGenPath $newGenPath
  '';

  home.file.".config/fish/conf.d/add_bin_to_path.fish".text = ''
    fish_add_path "$HOME/bin"
  '';
}
