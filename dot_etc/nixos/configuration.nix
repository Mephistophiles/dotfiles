# vim:expandtab ts=2 sw=2
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  mypkgs = pkgs.callPackage pkgs/default.nix { inherit pkgs; };
  graphics = "awesomewm";
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
    tmpOnTmpfs = true;
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
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  virtualisation.docker.enable = true;

  # List services that you want to enable:
  services = {
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    xserver = {
      enable = true;

      desktopManager = { xterm.enable = false; };

      # Enable touchpad support (enabled default in most desktopManager).
      libinput = { enable = true; };

      # Configure keymap in X11
      layout = "us,ru";
      xkbOptions = "grp:alt_shift_toggle,grp_led:scroll,caps:backspace";
    };
    # Enable CUPS to print documents.
    # printing.enable = true;

    cron = {
      enable = true;
      systemCronJobs = [
        "*/5 * * * *  mzhukov   /home/mzhukov/.etc/sync.sh"
        "*/5 * * * *  mzhukov   cat ~/.config/starship.toml > ~/.dotfiles/dot_config/readonly_starship.toml"
        "*/5 * * * *  mzhukov   cat ~/.config/alacritty/alacritty.yml > ~/.dotfiles/dot_config/alacritty/alacritty.yml"
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
        IdleAction=suspend
        IdleActionSec=5h
      '';
    };

    upower = { enable = true; };
    autorandr =
      let
        laptop = "00ffffffffffff000dae0416000000000b1d0104a524147802ee95a3544c99260f505400000001010101010101010101010101010101b43b804a713834403020350063c71000001a000000fe004e3136314843412d4541330a20000000fe00434d4e0a202020202020202020000000fe004e3136314843412d4541330a200030";
        huawei_mateview_gt34_dp = "00ffffffffffff0022f6256a22f680c01a200103805021780a54b1ac5047a426115054bfcf0081408180714f81c0b300d1c0010101014ed470a0d0a0465030403a001d4e3100001ce77c70a0d0a0295030203a001d4e3100001a000000fd0030901ea03c010a202020202020000000fc005a51452d4342410a202020202001b4020344b14b1f9014010304121305025a83010000e200d567030c001000384067d85dc4017880006d1a000002013090e60000000000e305c081e30f0000e606050166661c565e00a0a0a02950302035001d4e3100001a9d6770a0d0a0225030203a001d4e3100001a464714a0a0381f40302018041d4e3100001a00000000009b";
        huawei_mateview_gt34_hdmi = "00ffffffffffff0022f6256a22f680c01a200103805021780a54b1ac5047a426115054bfcf0081408180714f81c0b300d1c0010101014ed470a0d0a0465030403a001d4e3100001ce77c70a0d0a0295030203a001d4e3100001a000000fd0030901ea03c010a202020202020000000fc005a51452d4342410a202020202001b4020344b14b1f9014010304121305025a83010000e200d567030c002000384067d85dc4017880006d1a000002013090e60000000000e305c081e30f0000e606050166661c565e00a0a0a02950302035001d4e3100001a9d6770a0d0a0225030203a001d4e3100001a464714a0a0381f40302018041d4e3100001a00000000008b";
        monitor_setup = mode: ident: fingerprint: {
          fingerprint = {
            "${ident}" = fingerprint;
          };
          config = {
            "${ident}" = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = mode;
            };
          };
        };
        huawei_mateview = ident: fingerprint: monitor_setup "3440x1440" ident fingerprint;
      in
      {
        enable = true;
        profiles = {
          laptop = monitor_setup "1920x1080" "eDP" laptop;
          "docked-dp0" = huawei_mateview "DisplayPort-0" huawei_mateview_gt34_dp;
          "docked-dp1" = huawei_mateview "DisplayPort-1" huawei_mateview_gt34_dp;
          "internal-hdmi" = huawei_mateview "HDMI-A-0" huawei_mateview_gt34_hdmi;
        };
      };
    acpid = {
      enable = true;
      handlers = {
        LID = {
          action = "${pkgs.unstable.autorandr}/bin/autorandr --batch --change --default default";
          event = "button/lid.*";
        };
      };
    };
  };

  systemd = {
    sleep = {
      extraConfig = ''
        HibernateDelaySec=1h
      '';
    };
  };

  # Enable sound.
  sound.enable = true;

  hardware = {
    pulseaudio.enable = true;
    bluetooth.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    # defaultUserShell = "/run/current-system/sw/bin/fish";
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs = {
    fish.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    dconf.enable = true;
    fuse = { userAllowOther = true; };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # rust stuff
    unstable.bat
    unstable.cargo-bloat
    unstable.cargo-cache
    unstable.cargo-diet
    unstable.cargo-edit
    unstable.cargo-expand
    unstable.cargo-insta
    unstable.cargo-nextest
    unstable.cargo-outdated
    unstable.cargo-public-api
    unstable.cargo-release
    unstable.cargo-tarpaulin
    unstable.cargo-udeps
    unstable.cargo-watch
    unstable.cargo-whatfeatures
    unstable.choose
    unstable.difftastic
    unstable.dua
    unstable.exa
    unstable.fd
    unstable.hyperfine
    unstable.inferno
    unstable.procs
    unstable.ripgrep
    unstable.ruplacer
    unstable.rust-analyzer
    unstable.rustup
    unstable.simple-http-server
    unstable.watchexec
    unstable.xh
    unstable.zoxide

    # gui
    arandr
    evince
    firefox
    gimp
    gnome3.file-roller
    gnome3.gnome-calculator
    gnome3.gnome-disk-utility
    gnome3.gnome-themes-extra
    gnome3.nautilus
    unstable.josm
    libreoffice
    meld
    thunderbird
    unstable.tdesktop

    # text editors
    micro
    (neovim.override { vimAlias = true; })
    unstable.helix
    unstable.vscode
    xfce.mousepad
    # unstable.jetbrains.clion
    # unstable.obsidian

    # utils
    age
    bitwarden
    bitwarden-cli
    unstable.bottom
    brightnessctl
    unstable.chezmoi
    curl
    docker-compose
    dunst
    file
    fzf
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
    taskwarrior
    time
    unp
    unzip
    vifm
    wally-cli
    wcalc
    wget
    xclip
    zip

    # nixos
    deadnix
    nix-index
    nix-prefetch
    nixos-option
    nixpkgs-fmt
    statix
    unstable.home-manager
    unstable.nixpkgs-review

    # self packaged
    mypkgs.telegram-send

    # programming
    cmake
    gcc_multi
    git
    gitAndTools.delta
    gitAndTools.gh
    gnumake
    lua
    python310
    stylua

    tig
    unstable.julia-stable-bin
    unstable.lazydocker
    unstable.lazygit
    unstable.zlib
    valgrind
    yarn

    # programming LSP
    clang-tools
    # efm-langserver
    gdb
    llvmPackages_latest.clang
    llvmPackages_latest.llvm
    rnix-lsp
    sumneko-lua-language-server
    unstable.nodePackages.typescript-language-server
    unstable.nodePackages.vls
    # unstable.python310Packages.python-lsp-server
    # unstable.vscode-extensions.llvm-org.lldb-vscode

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
    networkmanager.enable = true;

    wg-quick = { interfaces.wg0 = config.vault.wireguard; };

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    #
    # removed hosts
    # 192.168.161.102 clipboard
    extraHosts = ''
      192.168.161.7 rd
      192.168.161.102 taskd
      192.168.100.3 listserv.msk.dlink.ru
      192.168.100.23 mailman.dlink.ru
    '';
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      fira-code
      fira-code-symbols
      font-awesome
      fontconfig
      freetype
      #hack-font
      jetbrains-mono
      #liberation_ttf
      material-icons
      nerdfonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      #siji
      #source-code-pro
      #source-sans-pro
      #source-serif-pro
      #ubuntu_font_family
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

