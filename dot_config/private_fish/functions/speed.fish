function speed
	if test -d /home/builder/SDKS/SPEED/
		if count $argv > /dev/null
			cd $argv
		else
			cd /home/builder/SDKS/SPEED/
		end
	else
		return 1
	end
end
complete --command speed --arguments '(CDPATH=/home/builder/SDKS/SPEED/ __fish_complete_cd)'


