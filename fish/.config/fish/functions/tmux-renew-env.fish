function tmux-renew-env --description "Update env under tmux"
	for line in (tmux show-env)
		if string match -rq '^-' -- "$line"
			set -l var (string sub -s 2 -- $line)
			echo "unexport $var"
			set -u "$var"
		else
			set -l var (string split -f1 = -- $line)
			set -l val (string split -f2 = -- $line)
			echo "export $var=$val"
			set -x "$var" "$val"
		end
	end
end
