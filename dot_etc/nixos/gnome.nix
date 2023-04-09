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
          version = "develop";
          src = super.fetchFromGitHub {
            owner = "PaperWM-community";
            repo = "PaperWM";
            rev = "f590f8b30f0c1962e2bc18f1a39355b0a72636cb";
            sha256 = "sha256-ngyTsls0RYQyepfwvNJDPdlGMRC2+woFCW4RVjsaPRU=";
          };
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
    unstable.gnomeExtensions.cpufreq
    gnomeExtensions.paperwm
    gnomeExtensions.system-monitor
    unstable.gnomeExtensions.vertical-overview
    unstable.gnomeExtensions.cleaner-overview
  ];
}
