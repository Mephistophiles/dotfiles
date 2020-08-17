function ssd -d "Change Directory to SSD"
	if test -n "$argv"
		if count $argv > /dev/null
			cd $argv
		else
			cd /home/builder/SDKS/SSD/
		end
	else
		cd /home/builder/SDKS/SSD/
	end
end
complete --command ssd --arguments '(CDPATH=/home/builder/SDKS/SSD/ __fish_complete_cd)'



