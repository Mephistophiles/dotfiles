{ pkgs, lib }:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "telegram-send";
  version = "0.34";

  src = pkgs.python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-KR9mU8FvA+vOz4FCIljrFk9XCNthC8d55of5Pta/oyQ=";
  };

  propagatedBuildInputs = [
    pkgs.python310Packages.appdirs
    pkgs.python310Packages.colorama
    pkgs.python310Packages.python-telegram-bot
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/telegram-rs/telegram-bot";
    description =
      "Send messages and files over Telegram from the command-line.";
    license = licenses.gpl3;
    maintainers = with maintainers; [ fridh ];
  };
}
