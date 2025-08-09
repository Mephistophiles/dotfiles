{ pkgs, ... }:

{
  services = {
    gnome.gnome-keyring.enable = true;

    xserver = {
      enable = true;

      desktopManager = { xterm.enable = false; };


      # Configure keymap in X11
      xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle,grp_led:scroll,caps:backspace";
      };
    };
  };

  environment.variables = {
    WINIT_X11_SCALE_FACTOR = "1.2";
  };
  programs = {
    amnezia-vpn = {
      enable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    # gui
    arandr
    evince
    # chromium
    firefox
    file-roller
    # gnome-calculator
    # gnome-disk-utility
    # gnome-themes-extra
    nautilus
    unstable.tdesktop

    vlc

    unstable.alacritty
    unstable.wezterm

    unstable.obsidian
    unstable.zed-editor
    # unstable.vscode
    # xfce.mousepad

    haskellPackages.greenclip

    transmission_4-gtk

    # networking
    networkmanagerapplet

  ];
}
