{ pkgs, ... }:

let
  solarized = {
    # Default colors
    primary = {
      background = "0x002b36";
      foreground = "0x839496";
    };

    # Normal colors
    normal = {
      black = "0x073642";
      red = "0xdc322f";
      green = "0x859900";
      yellow = "0xb58900";
      blue = "0x268bd2";
      magenta = "0xd33682";
      cyan = "0x2aa198";
      white = "0xeee8d5";
    };

    # Bright colors
    bright = {
      black = "0x002b36";
      red = "0xcb4b16";
      green = "0x586e75";
      yellow = "0x657b83";
      blue = "0x839496";
      magenta = "0x6c71c4";
      cyan = "0x93a1a1";
      white = "0xfdf6e3";
    };
  };
  tokyo_night = {
    # Tokyo Night theme, based on both:
    #   https://github.com/ghifarit53/tokyonight-vim
    #   https://github.com/enkia/tokyo-night-vscode-theme
    # Default colors
    primary = {
      background = "0x1a1b26";
      foreground = "0xa9b1d6";
    };

    # Normal colors
    normal = {
      black = "0x32344a";
      red = "0xf7768e";
      green = "0x9ece6a";
      yellow = "0xe0af68";
      blue = "0x7aa2f7";
      magenta = "0xad8ee6";
      cyan = "0x449dab";
      white = "0x787c99";
    };

    # Bright colors
    bright = {
      black = "0x444b6a";
      red = "0xff7a93";
      green = "0xb9f27c";
      yellow = "0xff9e64";
      blue = "0x7da6ff";
      magenta = "0xbb9af7";
      cyan = "0x0db9d7";
      white = "0xacb0d0";
    };
  };

  tokyo_night_storm = {
    # Default colors
    primary = {
      background = "0x24283b";
      foreground = "0xa9b1d6";
    };

    # Normal colors
    normal = {
      black = "0x32344a";
      red = "0xf7768e";
      green = "0x9ece6a";
      yellow = "0xe0af68";
      blue = "0x7aa2f7";
      magenta = "0xad8ee6";
      cyan = "0x449dab";
      white = "0x9699a8";
    };

    # Bright colors
    bright = {
      black = "0x444b6a";
      red = "0xff7a93";
      green = "0xb9f27c";
      yellow = "0xff9e64";
      blue = "0x7da6ff";
      magenta = "0xbb9af7";
      cyan = "0x0db9d7";
      white = "0xacb0d0";
    };
  };

in {
  programs = {
    alacritty = {
      enable = true;
      package = pkgs.unstable.alacritty;
      settings = {
        env.TERM = "xterm-256color";
        scrolling.history = 100000;
        selection.semantic_escape_chars = '',│`|"' ()[]{}<>\t'';
        font = {
          size = 11.0;
          normal = {
            family = "monospace";
            style = "Regular";
          };

          bold = {
            family = "monospace";
            style = "Bold";
          };

          italic = {
            family = "monospace";
            style = "Italic";
          };

          bold_italic = {
            family = "monospace";
            style = "Bold Italic";
          };

        };
        colors = tokyo_night_storm;
      };
    };
  };
}
