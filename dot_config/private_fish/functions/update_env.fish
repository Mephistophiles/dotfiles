function __select
  read --local --array --null arr
  echo $arr[$argv]
end

function update_env
	for line in (tmux show-env)
		if string match -q -- "-*" $line
			set -l NAME (string sub -s 2 -- $line)

			echo "set --unexport \"$NAME\" \"$VALUE\""
			set --unexport "$NAME"
		else
			set -l NAME (string split '=' $line | __select 1)
			set -l VALUE (string split '=' $line | __select 2..-1)

			echo "set --export \"$NAME\" \"$VALUE\""
			set --export "$NAME" "$VALUE"
		end
	end
end

