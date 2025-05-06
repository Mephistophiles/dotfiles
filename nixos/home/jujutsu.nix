{ pkgs, ... }:
{
  programs = {
    jujutsu = {
      enable = true;
      package = pkgs.unstable.jujutsu;
      settings = {
        user = {
          name = "Maxim Zhukov";
          email = "mussitantesmortem@gmail.com";
        };
        ui.default-command = "log";
      };
    };
  };
}
