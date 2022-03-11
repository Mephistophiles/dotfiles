set TAB_CHAR '	'

function __fish_redminer_using_command
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

function __fish_redminer_need_append_pr_command
  set -l cmd (commandline -opc)
  set -l cmd_count (count $cmd)
  set -l pr_count (math $cmd_count - 3)
  set -l last_arg $cmd[$cmd_count]

  if [ $pr_count -lt 0 ]
    return 1
  end

  if [ $cmd[2] != "pr" ]
    return 1
  end

  if [ (count $argv) -gt 0 ]
    if [ $argv[1] = $last_arg ]
      return 0
    else
      return 1
    end
  else
    if [ (math $pr_count % 2) -eq 1 ]
        return 1
    end

    return 0
  end

  return 1
end

function __fish_redminer_need_append_set_command
# function __fish_redminer_using_batch_command
  set -l cmd (commandline -opc)
  set -l cmd_count (count $cmd)
  set -l batch_count (math $cmd_count - 4)
  set -l last_arg $cmd[$cmd_count]

  if [ $batch_count -lt 0 ]
    return 1
  end

  if [ $cmd[2] != "timer" ]
    return 1
  end

  if [ $cmd[3] != "set" ]
    return 1
  end

  if [ (count $argv) -gt 0 ]
    if [ $argv[1] = $last_arg ]
      return 0
    else
      return 1
    end
  else
    if [ (math $batch_count % 2) -eq 1 ]
        return 1
    end

    return 0
  end

  return 1
end

function __fish_redminer_need_append_batch_command
# function __fish_redminer_using_batch_command
  set -l cmd (commandline -opc)
  set -l cmd_count (count $cmd)
  set -l batch_count (math $cmd_count - 4)
  set -l last_arg $cmd[$cmd_count]

  if [ $batch_count -lt 0 ]
    return 1
  end

  if [ $cmd[2] != "timer" ]
    return 1
  end

  if [ $cmd[3] != "batch" ]
    return 1
  end

  if [ (count $argv) -gt 0 ]
    if [ $argv[1] = $last_arg ]
      return 0
    else
      return 1
    end
  else
    if [ (math $batch_count % 2) -eq 1 ]
        return 1
    end

    return 0
  end

  return 1
end

function __fish_redminer_timer_sort
    sed -e '/(running)/s/^/1:/' -e '/(suspended)/s/^/2:/' | sort | sed 's/^[[:digit:]]\+://'
end

function __fish_redminer_list_issues
    redminer tickets | sed 's/^#//'
end

function __fish_redminer_list_staged_timers
    redminer timer list_porcelain staged | __fish_redminer_timer_sort | sed "s/:/$TAB_CHAR/"
end

function __fish_redminer_list_non_staged_timers
    redminer timer list_porcelain | __fish_redminer_timer_sort | sed "s/:/$TAB_CHAR/"
end

function __fish_redminer_list_to_commit_timers
    redminer timer list_porcelain to_commit | __fish_redminer_timer_sort | sed "s/:/$TAB_CHAR/"
end

function __fish_redminer_list_running_timers
    redminer timer list_porcelain | __fish_redminer_timer_sort | grep running | sed "s/:/$TAB_CHAR/"
end

function __fish_redminer_list_suspended_timers
    redminer timer list_porcelain | __fish_redminer_timer_sort | grep suspended | sed "s/:/$TAB_CHAR/"
end

function __fish_redminer_list_issues_wo_timers
    redminer tickets_wo_timers | sed 's/^#//'
end

function __fish_redminer_list_timers
    redminer tickets | sed 's/^#//'
end

function __fish_redminer_need_append_batch_command2
    set -l cmd (commandline -opc)

    set -l cmd_count (math (count $cmd) - 3)

    if [ (math $cmd_count % 2) -eq 0 ]
        return 1
    end

    return 0
end

complete -f -c redminer -d 'redmine timeentry cli'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'init' -d 'init configuration'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'fetch' -d 'fetch issues or selected issue by id'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'gc' -d 'run garbage collector'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'tickets' -d 'show list of tickets'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'ticket_List' -d 'show list of tickets (homan-readable)'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'ticket_info' -d 'show info about the ticket'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'timer' -d 'timer ops'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'report' -d 'generate report'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'week_report' -d 'generate XLS week report'
complete -f -c redminer -n '__fish_redminer_using_command' -a 'pr' -d 'create merge request'

complete -f -c redminer -n '__fish_redminer_using_command fetch' -k -a '(__fish_redminer_list_issues)' -d 'select issue id'

complete -f -c redminer -n '__fish_redminer_using_command ticket_info' -k -a '(__fish_redminer_list_issues)' -d 'select issue'

complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'new' -d 'create new timer for the issue'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'batch' -d 'create new timer for the issue in batch mode'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'del' -d 'delete timer'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'commit' -d 'commit changes for the timer'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'resume' -d 'resume the timer'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'suspend' -d 'suspend the timer'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'push' -d 'push staged timers'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'list' -d 'list of the timers'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'status' -d 'show timer status (aka git status)'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'report' -d 'generate report from archived timers'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'restore' -d 'move timer from staged'
complete -f -c redminer -n '__fish_redminer_using_command timer' -a 'set' -d 'set timer ops'

complete -f -c redminer -n '__fish_redminer_using_command timer commit' -k -a '(__fish_redminer_list_non_staged_timers)' -d 'select issue'
complete -f -c redminer -n '__fish_redminer_using_command timer restore' -k -a '(__fish_redminer_list_staged_timers)' -d 'select issue'
complete -f -c redminer -n '__fish_redminer_using_command timer suspend' -k -a '(__fish_redminer_list_running_timers)' -d 'select issue'
complete -f -c redminer -n '__fish_redminer_using_command timer resume' -k -a '(__fish_redminer_list_suspended_timers)' -d 'select issue'
complete -f -c redminer -n '__fish_redminer_using_command timer new' -k -a '(__fish_redminer_list_issues_wo_timers)' -d 'select issue'
complete -f -c redminer -n '__fish_redminer_using_command timer del' -k -a '(__fish_redminer_list_to_commit_timers)' -d 'select issue'
complete -f -c redminer -n '__fish_redminer_using_command timer set' -k -a '(__fish_redminer_list_to_commit_timers)' -d 'select issue'
complete -f -c redminer -n '__fish_redminer_using_command timer batch' -a '(__fish_redminer_list_issues_wo_timers)' -d 'select offset'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command' -a 'offset' -d 'select offset'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command' -a 'offset_ext' -d 'select offset'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command' -a 'type' -d 'select type'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command' -a 'note' -d 'select note'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command' -a 'create' -d 'select create date'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command' -a 'commit' -d 'select commit id'

complete -f -c redminer -n '__fish_redminer_need_append_batch_command type' -a 'designing' -d 'designing'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command type' -a 'development' -d 'development'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command type' -a 'testing' -d 'testing'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command type' -a 'debugging' -d 'debugging'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command type' -a 'support' -d 'support'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command type' -a 'discussion' -d 'discussion'

complete -f -c redminer -n '__fish_redminer_need_append_batch_command create' -a 'today' -d 'today'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command create' -a 'yesterday' -d 'yesterday'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command create' -a 'tomorrow' -d 'tomorrow'
complete -f -c redminer -n '__fish_redminer_need_append_batch_command create' -a '"last fri"' -d 'last fri'

complete -f -c redminer -n '__fish_redminer_need_append_set_command' -a 'offset' -d 'select offset'
complete -f -c redminer -n '__fish_redminer_need_append_set_command' -a 'offset_ext' -d 'select offset'
complete -f -c redminer -n '__fish_redminer_need_append_set_command' -a 'type' -d 'select type'
complete -f -c redminer -n '__fish_redminer_need_append_set_command' -a 'note' -d 'select note'
complete -f -c redminer -n '__fish_redminer_need_append_set_command' -a 'create' -d 'select create date'
complete -f -c redminer -n '__fish_redminer_need_append_set_command' -a 'commit' -d 'select commit id'

complete -f -c redminer -n '__fish_redminer_need_append_set_command type' -a 'designing' -d 'designing'
complete -f -c redminer -n '__fish_redminer_need_append_set_command type' -a 'development' -d 'development'
complete -f -c redminer -n '__fish_redminer_need_append_set_command type' -a 'testing' -d 'testing'
complete -f -c redminer -n '__fish_redminer_need_append_set_command type' -a 'debugging' -d 'debugging'
complete -f -c redminer -n '__fish_redminer_need_append_set_command type' -a 'support' -d 'support'
complete -f -c redminer -n '__fish_redminer_need_append_set_command type' -a 'discussion' -d 'discussion'

complete -f -c redminer -n '__fish_redminer_need_append_set_command note' -a '@patch' -d 'Patch was accepted'
complete -f -c redminer -n '__fish_redminer_need_append_set_command note' -a '@patch_rej' -d 'Patch was rejected'

complete -f -c redminer -n '__fish_redminer_need_append_set_command create' -a 'today' -d 'today'
complete -f -c redminer -n '__fish_redminer_need_append_set_command create' -a 'yesterday' -d 'yesterday'
complete -f -c redminer -n '__fish_redminer_need_append_set_command create' -a 'tomorrow' -d 'tomorrow'
complete -f -c redminer -n '__fish_redminer_need_append_set_command create' -a '"last fri"' -d 'last friday'

complete -f -c redminer -n '__fish_redminer_need_append_pr_command' -a 'milestone' -d 'select milestone'
complete -f -c redminer -n '__fish_redminer_need_append_pr_command milestone' -a 'build' -d 'bump build version'
complete -f -c redminer -n '__fish_redminer_need_append_pr_command milestone' -a 'minor' -d 'bump minor version'

complete -f -c redminer -n '__fish_redminer_need_append_pr_command' -a 'assignee' -d 'select assignee'
complete -f -c redminer -n '__fish_redminer_need_append_pr_command assignee' -a 'asafonov' -d 'Alexander Safonov'
complete -f -c redminer -n '__fish_redminer_need_append_pr_command assignee' -a 'kbulygin' -d 'Kirill Bulygin'
complete -f -c redminer -n '__fish_redminer_need_append_pr_command assignee' -a 'mzhukov' -d 'Maxim Zhukov'
complete -f -c redminer -n '__fish_redminer_need_append_pr_command assignee' -a 'rkarpov' -d 'Roman Karpov'
complete -f -c redminer -n '__fish_redminer_need_append_pr_command assignee' -a 'vyaichkin' -d 'Vladimir Yaichkin'

complete -f -c redminer -n '__fish_redminer_need_append_pr_command' -a 'reviewer' -d 'select reviewer'
complete -f -c redminer -n '__fish_redminer_need_append_pr_command reviewer' -a 'asafonov' -d 'Alexander Safonov'
complete -f -c redminer -n '__fish_redminer_need_append_pr_command reviewer' -a 'mzhukov' -d 'Maxim Zhukov'
