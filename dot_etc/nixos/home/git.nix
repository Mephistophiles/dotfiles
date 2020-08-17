{ config, pkgs, lib, ... }:

{
  programs = {
    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "Maxim Zhukov";
      userEmail = "mussitantesmortem@gmail.com";
      signing.key = "7146F5C513417782";
      extraConfig = {
        core = {
          editor = "nvim";
          # hookPaths = "~/.git-templates/hooks/";
          pager = "~/bin/git-pager";
        };
        merge = { tool = "vimdiff"; };
        mergetool = {
          vimdiff = {
            cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
          };
        };
        color = { ui = "auto"; };
        pull = { rebase = true; };
        # init = { templateDir = "~/.git-templates"; };
        delta = { line-numbers = true; };
      };
      includes = [{
        condition = "gitdir:/home/mzhukov/WORK/";
        contents = { user = { email = "mzhukov@dlink.ru"; }; };
      }];
    };
  };
}
