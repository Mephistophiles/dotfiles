function cd_ticket -d "Change directory to ticket"
	if test -d /home/builder/SDKS/
		if count $argv > /dev/null
			cd $argv
		else
			cd /home/builder/SDKS/
		end
	else
		return 1
	end
end
complete --command cd_ticket --arguments '(CDPATH=/home/builder/SDKS/ __fish_complete_cd)' --no-files

