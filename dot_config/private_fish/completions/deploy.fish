function __fish_deploy_using_command
  set cmd (commandline -opc)
  echo argvc (count $argv) >>/tmp/argv.count
  echo argv $argv >> /tmp/argv.count
  echo cmdc (count $cmd) >> /tmp/argv.count
  echo cmd $cmd >> /tmp/argv.count
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

function __fish_deploy_list_profiles
	sed -r -e 's/#.*$//' -e '/^$/d' -e 's#/#-#' /home/builder/SDKS/DEPLOY/profiles_list.cfg
end

complete -f -c deploy -d 'deploy sdk'
complete -f -c deploy -n '__fish_deploy_using_command' -a 'copy' -d 'action'
complete -f -c deploy -n '__fish_deploy_using_command copy' -a 'profile' -d 'select profile'
complete -f -c deploy -n '__fish_deploy_using_command copy profile' -a '(__fish_deploy_list_profiles)' -d 'select profile'

