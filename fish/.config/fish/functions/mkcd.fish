function mkcd --description "mkdir && cd"
	mkdir -pv "$argv" && cd "$argv"
end
