{ config, pkgs, lib, ... }: {
  programs = {
    kitty = {
      enable = true;

      settings = {
        font_size = "12.0";

        # solarized theme
        background = "#002b36";
        foreground = "#839496";

        # selection_foreground            #000000
        # selection_background            #fffacd

        #: Cursor colors

        # cursor                          #cccccc
        # cursor_text_color               #111111

        #: URL underline color when hovering with mouse

        # url_color                       #0087bd

        #: kitty window border colors and terminal bell colors

        # active_border_color             #00ff00
        # inactive_border_color           #cccccc
        # bell_border_color               #ff5a00
        # visual_bell_color               none

        #: OS Window titlebar colors

        # wayland_titlebar_color          system
        # macos_titlebar_color            system

        #: Tab bar colors

        # active_tab_foreground           #000
        # active_tab_background           #eee
        # inactive_tab_foreground         #444
        # inactive_tab_background         #999
        # tab_bar_background              none
        # tab_bar_margin_color            none

        #: Colors for marks (marked text in the terminal)

        # mark1_foreground black
        # mark1_background #98d3cb
        # mark2_foreground black
        # mark2_background #f2dcd3
        # mark3_foreground black
        # mark3_background #f274bc

        #: The basic 16 colors

        #: black
        color0 = "#073642";
        color8 = "#002b36";

        #: red
        color1 = "#dc322f";
        color9 = "#cb4b16";

        #: green
        color2 = "#859900";
        color10 = "#586e75";

        #: yellow
        color3 = "#b58900";
        color11 = "#657b83";

        #: blue
        color4 = "#268bd2";
        color12 = "#839496";

        #: magenta
        color5 = "#d33682";
        color13 = "#6c71c4";

        #: cyan
        color6 = "#2aa198";
        color14 = "#93a1a1";

        #: white
        color7 = "#eee8d5";
        color15 = "#fdf6e3";

        #: You can set the remaining 240 colors as color16 to color255.
      };
    };
  };
}

