# Git version checking

# Check if main exists and use instead of master
function git_main_branch
  command git rev-parse --git-dir &>/dev/null || return
  set -l branch

  for branch in main trunk
    if command git show-ref -q --verify refs/heads/$branch
      echo $branch
      return
    end
  end
  echo master
end

abbr --add 'g' 'git'

abbr --add 'ga' 'git add'
abbr --add 'gaa' 'git add --all'
abbr --add 'gapa' 'git add --patch'
abbr --add 'gau' 'git add --update'
abbr --add 'gav' 'git add --verbose'
abbr --add 'gap' 'git apply'
abbr --add 'gapt' 'git apply --3way'

abbr --add 'gb' 'git branch'
abbr --add 'gba' 'git branch -a'
abbr --add 'gbd' 'git branch -d'
abbr --add 'gbda' 'git branch --no-color --merged | command grep -vE "^(\+|\*|\s*((git_main_branch)|development|develop|devel|dev)\s*$)" | command xargs -n 1 git branch -d'
abbr --add 'gbD' 'git branch -D'
abbr --add 'gbl' 'git blame -b -w'
abbr --add 'gbnm' 'git branch --no-merged'
abbr --add 'gbr' 'git branch --remote'
abbr --add 'gbs' 'git bisect'
abbr --add 'gbsb' 'git bisect bad'
abbr --add 'gbsg' 'git bisect good'
abbr --add 'gbsr' 'git bisect reset'
abbr --add 'gbss' 'git bisect start'

abbr --add 'gc' 'git commit -v'
abbr --add 'gc!' 'git commit -v --amend'
abbr --add 'gcn!' 'git commit -v --no-edit --amend'
abbr --add 'gca' 'git commit -v -a'
abbr --add 'gca!' 'git commit -v -a --amend'
abbr --add 'gcan!' 'git commit -v -a --no-edit --amend'
abbr --add 'gcans!' 'git commit -v -a -s --no-edit --amend'
abbr --add 'gcam' 'git commit -a -m'
abbr --add 'gcsm' 'git commit -s -m'
abbr --add 'gcb' 'git checkout -b'
abbr --add 'gcf' 'git config --list'
abbr --add 'gcl' 'git clone --recurse-submodules'
abbr --add 'gclean' 'git clean -id'
abbr --add 'gpristine' 'git reset --hard && git clean -dffx'
abbr --add 'gcm' 'git checkout (git_main_branch)'
abbr --add 'gcd' 'git checkout develop'
abbr --add 'gcmsg' 'git commit -m'
abbr --add 'gco' 'git checkout'
abbr --add 'gcount' 'git shortlog -sn'
abbr --add 'gcp' 'git cherry-pick'
abbr --add 'gcpa' 'git cherry-pick --abort'
abbr --add 'gcpc' 'git cherry-pick --continue'
abbr --add 'gcs' 'git commit -S'

abbr --add 'gd' 'git diff'
abbr --add 'gdca' 'git diff --cached'
abbr --add 'gdcw' 'git diff --cached --word-diff'
abbr --add 'gdct' 'git describe --tags (git rev-list --tags --max-count=1)'
abbr --add 'gds' 'git diff --staged'
abbr --add 'gdt' 'git diff-tree --no-commit-id --name-only -r'
abbr --add 'gdw' 'git diff --word-diff'

function gdnolock -w git-diff
  git diff "$argv" ":(exclude)package-lock.json" ":(exclude)*.lock"
end

function gdv -w git-diff
    git diff -w "$argv" | view -
end

abbr --add 'gf' 'git fetch'
# --jobs=<n> was added in git 2.8
abbr --add 'gfa' 'git fetch --all --prune --jobs=10'
abbr --add 'gfo' 'git fetch origin'

abbr --add 'gfg' 'git ls-files | grep'

abbr --add 'gg' 'git gui citool'
abbr --add 'gga' 'git gui citool --amend'

#function ggf -w git-checkout
#  [[ (count $argv) != 1 ]] && local b="(git_current_branch)"
#  git push --force origin "${b:=$1}"
#end
#
#function ggfl -w git-checkout
#  [[ (count $argv) != 1 ]] && local b="(git_current_branch)"
#  git push --force-with-lease origin "${b:=$1}"
#end
#
#function ggl -w git-checkout
#  if [[ (count $argv) != 0 ]] && [[ (count $argv) != 1 ]]
#    git pull origin "${*}"
#  else
#    [[ (count $argv) == 0 ]] && local b="(git_current_branch)"
#    git pull origin "${b:=$1}"
#  end
#end
#
#function ggp -w git-checkout
#  if [[ (count $argv) != 0 ]] && [[ (count $argv) != 1 ]]
#    git push origin "${*}"
#  else
#    [[ (count $argv) == 0 ]] && local b="(git_current_branch)"
#    git push origin "${b:=$1}"
#  end
#end
#
#
#function ggpnp -w git-checkout
#  if [[ (count $argv) == 0 ]]
#    ggl && ggp
#  else
#    ggl "${*}" && ggp "${*}"
#  end
#end
#
#function ggu -w git-checkout
#  [[ (count $argv) != 1 ]] && local b="(git_current_branch)"
#  git pull --rebase origin "${b:=$1}"
#end

abbr --add 'ggpur' 'ggu'
abbr --add 'ggpull' 'git pull origin "(git_current_branch)"'
abbr --add 'ggpush' 'git push origin "(git_current_branch)"'

abbr --add 'ggsup' 'git branch --set-upstream-to=origin/(git_current_branch)'
abbr --add 'gpsup' 'git push --set-upstream origin (git_current_branch)'

abbr --add 'ghh' 'git help'

abbr --add 'gignore' 'git update-index --assume-unchanged'
abbr --add 'gignored' 'git ls-files -v | grep "^[[:lower:]]"'
abbr --add 'git-svn-dcommit-push' 'git svn dcommit && git push github (git_main_branch):svntrunk'

abbr --add 'gk' '\gitk --all --branches'
abbr --add 'gke' '\gitk --all (git log -g --pretty=%h)'

abbr --add 'gl' 'git pull'
abbr --add 'glg' 'git log --stat'
abbr --add 'glgp' 'git log --stat -p'
abbr --add 'glgg' 'git log --graph'
abbr --add 'glgga' 'git log --graph --decorate --all'
abbr --add 'glgm' 'git log --graph --max-count=10'
abbr --add 'glo' 'git log --oneline --decorate'
abbr --add 'glol' "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
abbr --add 'glols' "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat"
abbr --add 'glod' "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
abbr --add 'glods' "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
abbr --add 'glola' "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all"
abbr --add 'glog' 'git log --oneline --decorate --graph'
abbr --add 'gloga' 'git log --oneline --decorate --graph --all'

abbr --add 'gm' 'git merge'
abbr --add 'gmom' 'git merge origin/(git_main_branch)'
abbr --add 'gmt' 'git mergetool --no-prompt'
abbr --add 'gmtvim' 'git mergetool --no-prompt --tool=vimdiff'
abbr --add 'gmum' 'git merge upstream/(git_main_branch)'
abbr --add 'gma' 'git merge --abort'

abbr --add 'gp' 'git push'
abbr --add 'gpd' 'git push --dry-run'
abbr --add 'gpf' 'git push --force-with-lease'
abbr --add 'gpf!' 'git push --force'
abbr --add 'gpoat' 'git push origin --all && git push origin --tags'
abbr --add 'gpu' 'git push upstream'
abbr --add 'gpv' 'git push -v'

abbr --add 'gr' 'git remote'
abbr --add 'gra' 'git remote add'
abbr --add 'grb' 'git rebase'
abbr --add 'grba' 'git rebase --abort'
abbr --add 'grbc' 'git rebase --continue'
abbr --add 'grbd' 'git rebase develop'
abbr --add 'grbi' 'git rebase -i'
abbr --add 'grbm' 'git rebase (git_main_branch)'
abbr --add 'grbo' 'git rebase --onto'
abbr --add 'grbs' 'git rebase --skip'
abbr --add 'grev' 'git revert'
abbr --add 'grh' 'git reset'
abbr --add 'grhh' 'git reset --hard'
abbr --add 'groh' 'git reset origin/(git_current_branch) --hard'
abbr --add 'grm' 'git rm'
abbr --add 'grmc' 'git rm --cached'
abbr --add 'grmv' 'git remote rename'
abbr --add 'grrm' 'git remote remove'
abbr --add 'grs' 'git restore'
abbr --add 'grset' 'git remote set-url'
abbr --add 'grss' 'git restore --source'
abbr --add 'grst' 'git restore --staged'
abbr --add 'grt' 'cd "(git rev-parse --show-toplevel || echo .)"'
abbr --add 'gru' 'git reset --'
abbr --add 'grup' 'git remote update'
abbr --add 'grv' 'git remote -v'

abbr --add 'gsb' 'git status -sb'
abbr --add 'gsd' 'git svn dcommit'
abbr --add 'gsh' 'git show'
abbr --add 'gsi' 'git submodule init'
abbr --add 'gsps' 'git show --pretty=short --show-signature'
abbr --add 'gsr' 'git svn rebase'
abbr --add 'gss' 'git status -s'
abbr --add 'gst' 'git status'

# use the default stash push on git 2.13 and newer
abbr --add 'gsta' 'git stash push'

abbr --add 'gstaa' 'git stash apply'
abbr --add 'gstc' 'git stash clear'
abbr --add 'gstd' 'git stash drop'
abbr --add 'gstl' 'git stash list'
abbr --add 'gstp' 'git stash pop'
abbr --add 'gsts' 'git stash show --text'
abbr --add 'gstu' 'git stash --include-untracked'
abbr --add 'gstall' 'git stash --all'
abbr --add 'gsu' 'git submodule update'
abbr --add 'gsw' 'git switch'
abbr --add 'gswc' 'git switch -c'

abbr --add 'gts' 'git tag -s'
abbr --add 'gtv' 'git tag | sort -V'
abbr --add 'gtl' 'gtl(){ git tag --sort=-v:refname -n -l "${1}*" }; noglob gtl'

abbr --add 'gunignore' 'git update-index --no-assume-unchanged'
abbr --add 'gunwip' 'git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
abbr --add 'gup' 'git pull --rebase'
abbr --add 'gupv' 'git pull --rebase -v'
abbr --add 'gupa' 'git pull --rebase --autostash'
abbr --add 'gupav' 'git pull --rebase --autostash -v'
abbr --add 'glum' 'git pull upstream (git_main_branch)'

abbr --add 'gwch' 'git whatchanged -p --abbrev-commit --pretty=medium'

abbr --add 'gam' 'git am'
abbr --add 'gamc' 'git am --continue'
abbr --add 'gams' 'git am --skip'
abbr --add 'gama' 'git am --abort'
abbr --add 'gamscp' 'git am --show-current-patch'

function grename
  if [ -z "$1" ] || [ -z "$2" ]
    echo "Usage: $0 old_branch new_branch"
    return 1
  end

  # Rename branch locally
  git branch -m "$1" "$2"
  # Rename branch in origin remote
  if git push origin :"$1"
    git push --set-upstream origin "$2"
  end
end
