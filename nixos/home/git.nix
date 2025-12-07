{ pkgs, lib, ... }:

{
  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user = {
          name = "Maxim Zhukov";
          email = "mussitantesmortem@gmail.com";
        };
        core = {
          editor = "nvim";
          pager = "~/bin/git-pager";
        };
        difftool = {
          delta = {
            cmd = ''delta "$LOCAL" "$REMOTE"'';
          };
          difft = {
            cmd = ''difft "$LOCAL" "$REMOTE"'';
          };
          difftastic = {
            cmd = ''difft "$LOCAL" "$REMOTE"'';
          };
          meld = {
            cmd = ''meld "$LOCAL" "$REMOTE"'';
          };
          nvim_difftool = {
            cmd = ''nvim -c "packadd nvim.difftool" -c "DiffTool $LOCAL $REMOTE"'';
          };
        };
        merge = {
          tool = "vimdiff";
        };
        mergetool = {
          vimdiff = {
            cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
          };
        };
        color = { ui = "auto"; };
        commit = { verbose = true; };
        pull = { rebase = true; };
        delta = {
          line-numbers = true;
          features = "tokio-night-storm";

          tokio-night-storm = {
            dark = true;
            hyperlinks = true;
            keep-plus-minus-markers = true;
            # git-moved-from-style = bold purple
            minus-style = ''syntax "#3f2d3d"'';
            minus-non-emph-style = ''syntax "#3f2d3d"'';
            minus-emph-style = ''syntax "#763842"'';
            minus-empty-line-marker-style = ''syntax "#3f2d3d"'';
            line-numbers-minus-style = "#b2555b";
            plus-style = ''syntax "#283b4d"'';
            plus-non-emph-style = ''syntax "#283b4d"'';
            plus-emph-style = ''syntax "#316172"'';
            plus-empty-line-marker-style = ''syntax "#283b4d"'';
            line-numbers-plus-style = "#266d6a";
            line-numbers-zero-style = "#3b4261";
          };
        };
      };
      lfs.enable = true;
    };
  };
}
