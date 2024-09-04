# vim:expandtab ts=2 sw=2
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, options, ... }:

let
  graphics = "awesomewm";
  #graphics = "gnome";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./variables.nix
    ./home/vault.nix
    ./hardware-configuration.nix
    ./host.nix
  ] ++ (if graphics == "gnome" then
    [ ./gnome.nix ]
  else if graphics == "awesomewm" then
    [ ./awesomewm.nix ]
  else
    abort "Invalid graphics!");

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
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    libinput = { enable = true; };
    opensnitch.enable = true;
    xserver = {
      enable = true;

      desktopManager = { xterm.enable = false; };


      # Configure keymap in X11
      xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle,grp_led:scroll,caps:backspace";
      };
    };
    # Enable CUPS to print documents.
    # printing.enable = true;

    cron = {
      enable = true;
      systemCronJobs = [
        "*/5 * * * *  mzhukov   /home/mzhukov/.etc/sync.sh"
        "*/5 * * * *  mzhukov   cat ~/.config/starship.toml > ~/.dotfiles/dot_config/readonly_starship.toml"
        "*/5 * * * *  mzhukov   cat ~/.config/rofi/config.rasi > ~/.dotfiles/dot_config/rofi/config.rasi"
      ];
    };

    openssh = { enable = true; };

    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        HandlePowerKey=suspend
      '';
    };

    upower = { enable = true; };
    autorandr =
      let
        laptop_edid = "00ffffffffffff000dae0416000000000b1d0104a524147802ee95a3544c99260f505400000001010101010101010101010101010101b43b804a713834403020350063c71000001a000000fe004e3136314843412d4541330a20000000fe00434d4e0a202020202020202020000000fe004e3136314843412d4541330a200030";
        huawei_mateview_gt34_edid = "00ffffffffffff0022f6256a22f680c01a200103805021780a54b1ac5047a426115054bfcf0081408180714f81c0b300d1c0010101014ed470a0d0a0465030403a001d4e3100001ce77c70a0d0a0295030203a001d4e3100001a000000fd0030901ea03c010a202020202020000000fc005a51452d4342410a202020202001b4020344b14b1f9000010304121300025a83010000e200d567030c002000184067d85dc4017880006d1a000002013090e60000000000e305c081e30f0000e606050166661c565e00a0a0a02950302035001d4e3100001a9d6770a0d0a0225030203a001d4e3100001a464714a0a0381f40302018041d4e3100001a0000000000c4";
      in
      {
        enable = true;
        defaultTarget = "laptop";
        profiles = {
          laptop = {
            fingerprint = { "eDP" = laptop_edid; };
            config = {
              "eDP" = { enable = true; primary = true; position = "0x0"; mode = "1920x1080"; };
            };
          };

          "laptop-dual" = {
            fingerprint = { "eDP" = laptop_edid; "DisplayPort-3" = huawei_mateview_gt34_edid; };
            config = {
              "eDP" = { enable = true; primary = false; position = "0x0"; mode = "1920x1080"; };
              "DisplayPort-3" = { enable = true; primary = true; position = "1920x0"; mode = "3440x1440"; };
            };
          };

          "laptop-docked" = {
            fingerprint = { "DisplayPort-3" = huawei_mateview_gt34_edid; };
            config = {
              "DisplayPort-3" = { enable = true; primary = true; position = "0x0"; mode = "3440x1440"; };
            };
          };
        };
      };
    acpid = {
      enable = true;
      handlers = {
        LID = {
          action = "${pkgs.autorandr}/bin/autorandr --batch --change --default laptop";
          event = "button/lid.*";
        };
      };
    };
    udev.extraRules = ''
      # Rules for Oryx web flashing and live training
      KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

      # Legacy rules for live training over webusb (Not needed for firmware v21+)
      # Rule for all ZSA keyboards
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
      # Rule for the Moonlander
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
      # Rule for the Ergodox EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
      # Rule for the Planck EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

      # Wally Flashing rules for the Ergodox EZ
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

      # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
      # Keymapp Flashing rules for the Voyager
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
    '';
  };

  # Enable sound.
  sound.enable = true;

  hardware = {
    pulseaudio.enable = true;
    bluetooth.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    extraUsers.mzhukov = {
      shell = pkgs.fish;
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
    WINIT_X11_SCALE_FACTOR = "1.2";
    EDITOR = "vim";
  };

  programs = {
    fish.enable = true;
    dconf.enable = true;

    fuse = { userAllowOther = true; };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # rust stuff
    unstable.bat
    unstable.bottom
    unstable.cargo-msrv
    unstable.difftastic
    unstable.dua
    unstable.eza
    unstable.fd
    unstable.hyperfine
    unstable.git-cliff
    # unstable.inferno
    unstable.igrep
    unstable.just
    unstable.procs
    unstable.ripgrep
    unstable.ruplacer
    unstable.rust-analyzer
    unstable.rustup
    unstable.simple-http-server
    unstable.tealdeer
    unstable.watchexec
    unstable.wezterm
    unstable.yazi
    unstable.zoxide

    # gui
    arandr
    evince
    chromium
    firefox
    gnome3.file-roller
    gnome3.gnome-calculator
    gnome3.gnome-disk-utility
    gnome3.gnome-themes-extra
    gnome3.nautilus
    unstable.tdesktop

    # text editors
    (unstable.neovim.override {
      vimAlias = true;
    })
    unstable.helix
    # unstable.obsidian
    # unstable.vscode
    # xfce.mousepad

    # utils
    age
    bitwarden-cli
    brightnessctl
    unstable.chezmoi
    clifm
    curl
    deadbeef-with-plugins
    docker-compose
    file
    fzf
    gnuplot
    haskellPackages.greenclip
    htop
    kitty
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
    time
    unzip
    vifm
    wally-cli
    wcalc
    wget
    xclip
    zip
    unstable.jq

    # nixos
    # devenv
    deadnix
    nix-du
    nix-index
    nix-prefetch
    nix-tree
    nixos-option
    nixpkgs-fmt
    nvd
    statix
    unstable.home-manager
    unstable.nixpkgs-review

    # home manager
    unstable.direnv
    unstable.evans
    unstable.tree-sitter
    acpi
    gopass
    gopls
    pavucontrol
    vlc

    # programming
    cmake
    gcc_multi
    git
    gitAndTools.delta
    gitAndTools.gh
    gnumake
    lua
    python3
    stylua
    shellcheck

    tig
    unstable.lazygit
    unstable.zlib
    yarn

    # networking
    networkmanagerapplet

    # programming LSP
    clang-tools
    gdb
    llvmPackages_latest.clang
    llvmPackages_latest.llvm
    unstable.nixd
    sumneko-lua-language-server
    unstable.nodePackages.vscode-json-languageserver
    unstable.nodePackages.jsonlint
    unstable.python3Packages.python-lsp-server

    # file systems
    btrfs-progs
  ];

  documentation.dev.enable = true;

  # Open ports in the firewall.
  # Or disable the firewall altogether.
  networking = {
    firewall.enable = true;
    firewall.allowedTCPPorts = [ ];
    firewall.allowedUDPPorts = [ ];

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networkmanager = {
      enable = true;
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
      nerdfonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
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
    PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
    nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2) || true
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}

