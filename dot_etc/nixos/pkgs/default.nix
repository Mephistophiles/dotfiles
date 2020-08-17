{ pkgs, ... }:

{
  # fw = pkgs.callPackage ./fw { };
  telegram-send = pkgs.callPackage ./telegram-send { };
  pushlock = pkgs.callPackage ./pushlock { };
  # matebook-applet = pkgs.callPackage ./matebook-applet { };
}
