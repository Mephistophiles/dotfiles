function groot --description "Goto directory of git root"
	cd "$(git rev-parse --show-toplevel)"
end
