# vim:expandtab ts=2 sw=2

{ stdenv, lib, fetchurl, pkgs, autoPatchelfHook, dpkg }:

let
  pname = "matebook-applet";
  version = "3.0.1";
  name = "${pname}-${version}";

in stdenv.mkDerivation {
  inherit name;
  version = version;

  src = fetchurl {
    url =
      "https://github.com/nekr0z/matebook-applet/releases/download/${version}/matebook-applet_${version}_amd64.deb";
    name = "${name}.deb";
    sha256 = "0grbnxwkbiqs28ia7nbrvqb88i16pqk3by3gppynnp7d0afxa3kl";
  };

  nativeBuildInputs = [ autoPatchelfHook dpkg ];
  buildInputs = with pkgs; [ gtk3 libayatana-appindicator-gtk3 ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out
    dpkg -x $src $out
    mv $out/usr/* $out/
    rmdir $out/usr/
    chmod go-w $out
  '';

  meta = with lib; {
    description = "System tray applet/control app for Huawei Matebook";
    homepage = "https://github.com/nekr0z/matebook-applet";
    license = licenses.gpl3;
    maintainers = with maintainers; [ mephistophiles ];
    platforms = platforms.linux;
  };
}
