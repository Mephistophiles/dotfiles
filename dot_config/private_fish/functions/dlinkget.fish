function __fish_get_profiles
	find /home/builder/SDKS/SSD/APPLY/DIR_QEMU_DBG/profiles/ -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
end
function dlinkget -d "Prepare dlink sdk"
	argparse --name=dlinkget 'w/work' 'b/branch=' -- $argv
	or return

	set -l profile $argv[1]
	set -l branch "$_flag_branch"

	if test -z "$branch"
		set branch "dsysinit"
	end

	git clone git@rd:sdk -b "$branch" $profile

	echo "$profile" > "$profile/.last_profile"

	echo "cd to $profile"
	cd "$profile"

	if set -q _flag_work
		pueue add -- debian make PROFILE="$profile"
	end
end


complete -c dlinkget -d "Prepare dlink sdk"
complete -c dlinkget -s w -d "Start build"
complete -c dlinkget -s c -d "Change directory"
complete -c dlinkget -s p  --no-files -d "Profile" -a '(__fish_get_profiles)'
complete -c dlinkget --no-files -a '(__fish_get_profiles)' -d 'Profile'
