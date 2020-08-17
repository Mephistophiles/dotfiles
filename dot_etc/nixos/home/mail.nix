# vim:expandtab ts=2 sw=2

{ config, pkgs, ... }:

let
  # sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
  unstable = import <nixos-unstable> { };
in {
  imports = [ ./i3status.nix ];

  # Let Home Manager install and manage itself.
  programs = {
    neomutt = {
      enable = true;
      vimKeys = true;
      editor = "vim";
      sidebar = { enable = true; };
    };

    mbsync.enable = true;
    msmtp.enable = true;
    notmuch = {
      enable = true;
      hooks = { preNew = "mbsync --all"; };
    };
  };

  accounts = {
    email = {
      maildirBasePath = "Maildir";
      accounts = {
        mzhukov = {
          neomutt.enable = true;
          primary = true;

          address = "mzhukov@dlink.ru";
          userName = "mzhukov";
          realName = "Maxim Zhukov";
          passwordCommand =
            "${pkgs.bitwarden-cli}/bin/bw get password d8006a64-9502-4d4b-8d6e-ad2c00cb1d67";
          imap.host = config.vault.dlinkHost;
          smtp.host = config.vault.dlinkHost;
          mbsync = {
            enable = true;
            create = "both";
            patterns = [ "*" "!Archives*" "!dovecot*" ];
          };
          msmtp.enable = true;
          notmuch.enable = true;
        };
      };
    };
  };
}
