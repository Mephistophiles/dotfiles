# vim:expandtab ts=2 sw=2

{ config, pkgs, lib, ... }:

{
  imports = [
    ./variables.nix
    ./home/alacritty.nix
    ./home/git.nix
    ./home/i3status.nix
    ./home/mail.nix
    ./home/starship.nix
    ./home/tmux.nix
    ./home/vault.nix
  ];

  home.packages = with pkgs; [
    unstable.evans
    unstable.evince
    unstable.jq
    unstable.tree-sitter
    acpi
    gopass
    gopls
    nodejs
    pavucontrol
    vlc
    unstable.rustup
  ];

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    go.enable = true;
    # rofi = {
    #   enable = true;
    #   theme = "solarized";
    #   extraConfig = {
    #     matching = "fuzzy";
    #     sort = true;
    #     sorting-method = "fzf";
    #   };
    # };
    gpg.enable = true;
  };

  services = {
    xidlehook = {
      enable = true;
      package = pkgs.unstable.xidlehook;
      not-when-fullscreen = true;
      not-when-audio = true;
      timers = [
        {
          delay = (15 * 60);
          command = "${pkgs.xorg.xset}/bin/xset dpms force off";
          canceller = "${pkgs.xorg.xset}/bin/xset dpms force on";
        }
        {
          delay = (1 * 60);
          command = "${pkgs.i3lock}/bin/i3lock -f -c 000000";
        }
      ];
    };
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
    dunst = {
      enable = true;
      waylandDisplay = lib.mkIf config.variables.withWayland "wayland-1";
      settings = {
        global = {
          geometry = "300x5-30+20";
          transparency = 0;
          frame_width = 0;
          frame_color = "#FFFFFF";
          font = "Monospace 6";
          format = ''
            <b>%s</b>
            %b'';
          indicate_hidden = "yes";
          ignore_newline = "no";
        };
        urgency_low = {
          # IMPORTANT: colors have to be defined in quotation marks.
          # Otherwise the '#' and following  would be interpreted as a comment.
          background = "#222222";
          foreground = "#888888";
          timeout = 10;
        };
        urgency_normal = {
          background = "#285577";
          foreground = "#ffffff";
          timeout = 10;
        };

        urgency_critical = {
          background = "#900000";
          foreground = "#ffffff";
          frame_color = "#ff0000";
          timeout = 10;
        };
      };
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mzhukov";
  home.homeDirectory = "/home/mzhukov";

  home.file.".config/fish/conf.d/add_bin_to_path.fish".text = ''
    fish_add_path "$HOME/bin"
  '';
}
