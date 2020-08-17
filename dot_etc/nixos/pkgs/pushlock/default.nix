{ lib, rustPlatform, pkgs, pkg-config, protobuf }:

rustPlatform.buildRustPackage rec {
  pname = "push-locker";
  version = "0.1.5";

  src = pkgs.fetchFromGitHub {
    owner = "Mephistophiles";
    repo = pname;
    rev = "v${version}";
    sha256 = "0crlxnaw753nyzsvqip2nc04y45cl3fxqqsjflw54ff7psrp37k7";
  };

  cargoSha256 = "1n6cpwfhhsr16bs1yhyc2c8bzbc23zicpcxsvcfhw7c6fm7gd256";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ];

  doCheck = false;

  postInstall = ''
    install -D -m755 "dist/pre-push" "$out/share/pushlock/pre-push"
  '';

  meta = with lib; {
    description = "A utility for merge window reservation. ";
    homepage = "https://github.com/Mephistophiles/push-locker";
    license = licenses.gpl3Plus;
    maintainers = [ ];
  };
}
