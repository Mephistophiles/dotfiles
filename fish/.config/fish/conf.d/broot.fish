function broot_key_bindings
  function __run_broot
    set -l fish_trace 2
    set -l current (commandline -ct)
    if [ -n "$current" ]
      set -f current "$current/"
      set -f cmd (broot $argv $current --conf ~/.config/fish/broot_select.hjson)
    else
      set -f cmd (broot $argv --conf ~/.config/fish/broot_select.hjson)
    end

    set -l path (path normalize "$current$cmd")
    commandline -tr $path
  end

  bind \ct '__run_broot --hidden'
  bind \cf '__run_broot --git-ignored --hidden'
end
broot_key_bindings
