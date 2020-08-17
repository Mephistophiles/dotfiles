function git-gc
	set -l before (git count-objects -vH | string collect -N)
	git gc --aggressive --prune=now
	set -l after (git count-objects -vH | string collect -N)

	if [ "$S" ]
		set DELTA_ARGS "--word-diff-regex=''"
	end

	diff -U3 (echo "$before" | psub) (echo "$after" | psub) | delta --dark \
	$DELTA_ARGS \
	--plus-style='normal #012800' \
	--plus-emph-style='normal auto' \
	--minus-style='normal #340001' \
	--minus-emph-style='normal auto' \
	--theme='Solarized (dark)'
end

