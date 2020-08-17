{ lib, rustPlatform, pkgs, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "fw";
  version = "2.7.0";

  src = pkgs.fetchFromGitHub {
    owner = "brocode";
    repo = pname;
    rev = "v2.7.0";
    sha256 = "1vywykyf3d9wf0sy7sywz9ljqvjc32cx9hxqx5cj2rs4n1dxs73i";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pkgs.openssl ];

  doCheck = false;

  cargoSha256 = "1vywykyf3d9wf0sy7sywz9ljqvjc32cx9hxqx5cj2rs4n1dxs73i";

  meta = with lib; {
    description = "workspace productivity booster ";
    homepage = "https://github.com/brocode/fw";
    license = licenses.unlicense;
    maintainers = [ maintainers.tailhook ];
  };
}
