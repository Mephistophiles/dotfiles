# vim:expandtab ts=2 sw=2

{ config, pkgs, lib, ... }:

{
  imports = [
    ./home/git.nix
    ./home/lazygit.nix
    ./home/jujutsu.nix
    ./home/rofi.nix
    ./home/tmux.nix
  ] ++ lib.optional (builtins.pathExists ./home/host.nix) ./home/host.nix;

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    go.enable = true;
    gpg.enable = true;
  };

  home.packages = with pkgs; [
    unstable.basedpyright
    unstable.black
    unstable.nodePackages.yaml-language-server
    unstable.pyright
    unstable.ruff
  ];

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
  home.stateVersion = "25.11";

  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    ${pkgs.unstable.nvd}/bin/nvd diff $oldGenPath $newGenPath
  '';
}
