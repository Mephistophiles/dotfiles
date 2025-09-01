{pkgs, ...}:

{
  programs = {
    lazygit = {
      enable = true;
      package = pkgs.unstable.lazygit;

      settings = {
        git = {
          autoFetch = false;
          paging = {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          };
        };
        gui = {
          useHunkModeInStagingView = false;
        };

        os = {
          editPreset = "nvim";
        };

        keybinding = {
          commits = {
            moveDownCommit = "<c-n>";
            moveUpCommit = "<c-p>";
          };
        };
        confirmOnQuit = false;
        quitOnTopLevelReturn = false;
      };
    };
  };
}
