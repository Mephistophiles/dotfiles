{ lib, rustPlatform, pkgs, pkg-config, protobuf }:

rustPlatform.buildRustPackage rec {
  pname = "clipboard-sync";
  version = "0.3.3";

  src = pkgs.fetchFromGitHub {
    owner = "Mephistophiles";
    repo = pname;
    rev = "682b6b6f852443ca7e40159608bebd2a7fb93bf8";
    sha256 = "0yazcqzgwdwkp7xpbx9yxmqqwinqc6yvqiqblmjcgssd0911ql9y";
  };

  cargoSha256 = "0lcymzin78j6prz8djrkfam39v4dqii5ckxw2v0nlaa19dnz0527";

  nativeBuildInputs = [ pkg-config pkgs.python3 pkgs.protobuf pkgs.rustfmt ];
  buildInputs = [ pkgs.xorg.libxcb ];
  PROTOC = "${protobuf}/bin/protoc";

  doCheck = false;

  meta = with lib; {
    description = "Clipboard sync daemon";
    homepage = "https://github.com/Mephistophiles/clipboard-sync";
    license = licenses.unlicense;
    maintainers = [ maintainers.tailhook ];
  };
}
