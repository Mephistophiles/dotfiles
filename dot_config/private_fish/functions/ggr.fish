function gtr --description "Goto git root"
	cd (git rev-parse --show-toplevel)
end
