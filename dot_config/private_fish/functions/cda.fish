function cda -d "Change directory to APPLY directory"
	set -l APPLY_DIR "/home/builder/SDKS/SSD/APPLY/DIR_QEMU_DBG"

	if test (count $argv) -eq 0
		cd $APPLY_DIR
	else if test -d $APPLY_DIR
		cd $APPLY_DIR/$argv
	else
		return 1
	end
end

complete --command cda --arguments "(CDPATH=/home/builder/SDKS/SSD/APPLY/DIR_QEMU_DBG __fish_complete_cd)" --no-files
