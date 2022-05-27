{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      gnomeExtensions = super.gnomeExtensions // {
        paperwm = super.gnomeExtensions.paperwm.overrideDerivation (old: {
          version = "pre-41.0";
          src = super.fetchFromGitHub {
            owner = "PaperWM-community";
            repo = "PaperWM";
            rev = "b66aaf13e8f4cdf0e2f9078fb3e75703535b822c";
            sha256 = "sha256-6AUUu63oWxRw9Wpxe0f7xvt7iilvQfhpAB8SYG4yP8Q=";
          };
          patches = old.patches or [ ] ++ [
            (self.fetchpatch {
              name = "pr-25.patch";
              url =
                "https://patch-diff.githubusercontent.com/raw/PaperWM-community/PaperWM/pull/25.patch";
              sha256 = "sha256-ISIL3bmNICf6I91LxGGmNXhIyehEF+7W9gfL8bq+g6M=";
            })
          ];
        });
      };
    })
  ];

  environment.gnome.excludePackages = (with pkgs; [ gnome-photos gnome-tour ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      gedit # text editor
      epiphany # web browser
      geary # email reader
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);

  programs = {
    dconf.enable = true;
    gpaste.enable = true;
  };
  environment.systemPackages = with pkgs; [
    gnome3.adwaita-icon-theme
    gnomeExtensions.caffeine
    gnomeExtensions.paperwm
    gnomeExtensions.system-monitor
    gnomeExtensions.vertical-overview
    unstable.gnomeExtensions.cleaner-overview
  ];
}
