# vim:expandtab ts=2 sw=2
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, options, ... }:

{
  imports = [
    # Include the results of the hardware scan.
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    tmp = {
      useTmpfs = true;
      tmpfsSize = "80%";
    };
    plymouth.enable = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    blacklistedKernelModules = [ ];
    supportedFilesystems = [ "btrfs" ];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "quiet" ];
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales =
      [ "en_US.UTF-8/UTF-8" "en_IE.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
    extraLocaleSettings = { LC_TIME = "en_IE.UTF-8"; };
  };

  virtualisation.docker.enable = true;

  # List services that you want to enable:
  services = {
    pcscd.enable = true; # smartcard support for yubikey
    gvfs.enable = true;
    opensnitch.enable = true;

    openssh = { enable = true; };
    upower = { enable = true; };
  };

  hardware = {
    bluetooth.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    extraUsers.mzhukov = {
      shell = pkgs.unstable.fish;
      isNormalUser = true;
      extraGroups = [
        "dialout"
        "plugdev"
        "docker"
        "networkmanager"
        "users"
        "wheel"
        "wireshark"
      ]; # Enable ‘sudo’ for the user.
    };
  };

  environment.variables = {
    PATH = "$HOME/.cargo/bin:$HOME/bin:$HOME/go/bin";
    EDITOR = "vim";
  };

  programs = {
    fish = {
      enable = true;
      package = pkgs.unstable.fish;
    };
    dconf.enable = true;

    fuse = { userAllowOther = true; };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # rust stuff
    unstable.bat
    unstable.bottom
    # unstable.cargo-msrv
    unstable.difftastic
    unstable.dua
    unstable.eza
    unstable.fd
    unstable.hyperfine
    # unstable.git-cliff
    # unstable.inferno
    unstable.igrep
    unstable.just
    unstable.procs
    unstable.ripgrep
    unstable.ruplacer
    unstable.rust-analyzer
    unstable.rustup
    # unstable.simple-http-server
    unstable.starship
    unstable.tealdeer
    unstable.watchexec
    unstable.yazi
    unstable.zoxide

    # text editors
    (unstable.neovim.override {
      vimAlias = true;
    })
    unstable.helix

    # utils
    curl
    file
    fzf
    # gnuplot
    htop
    linuxPackages.cpupower
    lm_sensors
    man-pages
    mc
    parallel-full
    procps
    psmisc
    rclone
    rsync
    sshfs-fuse
    stow
    time
    unzip
    vifm
    wcalc
    wget
    xclip
    zip
    unstable.jq

    # nixos
    # devenv
    nix-index
    nix-tree
    nixos-option
    nixpkgs-fmt
    unstable.comma
    unstable.nvd
    unstable.home-manager
    unstable.nixpkgs-review

    # home manager
    unstable.direnv
    unstable.tree-sitter
    acpi
    gopass
    pavucontrol

    # programming
    cmake
    git
    gitAndTools.delta
    gitAndTools.gh
    gnumake
    lua
    python3
    stylua
    shellcheck

    tig
    unstable.zlib
    yarn

    # programming LSP
    llvmPackages_latest.clang
    llvmPackages_latest.clang-tools
    llvmPackages_latest.llvm

    unstable.gopls
    unstable.nixd
    unstable.nodePackages.jsonlint
    unstable.nodePackages.vscode-json-languageserver
    unstable.python3Packages.python-lsp-server
    unstable.sumneko-lua-language-server

    # file systems
    btrfs-progs
  ];

  documentation.dev.enable = true;

  # Open ports in the firewall.
  # Or disable the firewall altogether.
  networking = {
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 80 1883 8123 9001 ];
    # firewall.allowedUDPPorts = [ ];

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networkmanager = {
      enable = true;
      plugins = lib.mkForce [ ];
      dispatcherScripts = [
        {
          source = ./70-wifi-wired.exclusive.sh;
        }
      ];
    };

    # wg-quick = { interfaces.wg0 = config.vault.wireguard; };
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      font-awesome
      fontconfig
      freetype
      jetbrains-mono
      material-icons
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      weather-icons

    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "Noto Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.unstable.nvd pkgs.nix ]}
    nvd --version-highlight xmas diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2) || true
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}

