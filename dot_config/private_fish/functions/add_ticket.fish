function add_ticket --description "Add new ticket directory"
	set -l do_cd false
	argparse -n add_ticket 'c/cd' -- $argv
	or return

	set -l ticket_number $argv[1]

	if set -q _flag_cd
		set -l do_cd true
	end

	if not string match --quiet --regex '^\d+$' $ticket_number
		set ticket_number (get_tickets | sort -r | fzf -d':' --with-nth 4.. | cut -d ':' -f4)
	end

	if not string match --quiet --regex '^\d+$' $ticket_number
		return 1
	end

	command add_ticket $ticket_number

	if set -q do_cd
		cd /home/builder/SDKS/$ticket_number/
	end
end

