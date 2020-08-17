function goto_ticket -d "Change directory to ticket directory"
	if test -d /home/builder/SDKS/
		cd /home/builder/SDKS/$argv
	else
		return 1
	end
end

function __fish_tickets
	set -l SDKS_DIR "/home/builder/SDKS/"

	for ticket in (exa --oneline --only-dirs --sort modified --reverse "$SDKS_DIR")
		set ticket "$SDKS_DIR/$ticket"
		if test -f "$ticket/info.yaml"
			set -l subject (yq '.issue.subject' "$ticket/info.yaml")

			echo (basename $ticket)\t$subject
			continue
		end

		if test -f "$ticket/info.txt"
			set -l subject (jq '.subject' "$ticket/info.txt")

			echo (basename $ticket)\t$subject
			continue
		end
	end
end

complete --keep-order -c goto_ticket -a '(__fish_tickets)' --no-files
