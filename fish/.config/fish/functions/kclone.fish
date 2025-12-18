function kclone
	set -l config "$argv[1]"

	k clone $config
	and cd $config
	and k loadconfig $config
end
