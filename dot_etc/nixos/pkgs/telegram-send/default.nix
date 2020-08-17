{ pkgs, lib }:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "telegram-send";
  version = "0.25";

  src = pkgs.python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "e6cda001a89e1cd02317fcd0456288a0cdd5aa56970dec6fbd83ad9af1db05ac";
  };

  propagatedBuildInputs = [
    pkgs.python39Packages.appdirs
    pkgs.python39Packages.colorama
    pkgs.python39Packages.python-telegram-bot
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
