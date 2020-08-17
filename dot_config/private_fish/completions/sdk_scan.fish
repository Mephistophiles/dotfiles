function __fish_sdk_scan_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) = (math (count $argv) + 1) ]
    for i in (seq (math (count $argv)))
      if not test $argv[$i] = $cmd[(math $i + 1)]
        return 1
      end
    end
    return 0
  end
  return 1
end

complete -f -c sdk_scan -d 'sdk manager'
complete -f -c redminer -n '__fish_sdk_scan_using_command' -a 'show' -d 'show uncommited and unpushed'
complete -f -c redminer -n '__fish_sdk_scan_using_command' -a 'show_unpushed' -d 'show unpushed'
complete -f -c redminer -n '__fish_sdk_scan_using_command' -a 'show_uncommited' -d 'show uncommited'
complete -f -c redminer -n '__fish_sdk_scan_using_command' -a 'push' -d 'push changes'
complete -f -c redminer -n '__fish_sdk_scan_using_command' -a 'create_patches' -d 'create patches'
complete -f -c redminer -n '__fish_sdk_scan_using_command' -a 'report' -d 'generate report by one issue'
complete -f -c redminer -n '__fish_sdk_scan_using_command' -a 'reportall' -d 'open the tickets in browser'

