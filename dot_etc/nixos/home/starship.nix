{ pkgs, ... }:

{
  programs = {
    starship = {
      enable = true;
      package = pkgs.unstable.starship;
      enableFishIntegration = true;
      settings = {
        battery = { format = "[$symbol $percentage]($style) "; };
        # right_format = lib.concatStrings [
        #   "$time"
        #   "$git_branch"
        #   "$git_commit"
        #   "$git_state"
        #   "$git_metrics"
        #   "$git_status"
        # ];
        git_status = {
          ahead = "↑\${count}";
          behind = "↓\${count}";
          deleted = "✘\${count}";
          diverged = "↑\${ahead_count}↓\${behind_count}";
          modified = "✚\${count}";
          renamed = "»\${count}";
          staged = "●\${count}";
          stashed = "⚑\${count}";
          untracked = "…\${count}";
        };
        memory_usage = {
          disabled = false;
          threshold = 75;
        };
        status = { disabled = false; };
	time.disabled = false;
        directory = {
          truncation_symbol = "…/";
          truncation_length = 3;
          truncate_to_repo = true;
        };
        lua.disabled = true;
        cmake.disabled = true;
      };
    };
  };
}
