function new-task  --description "Create new task env"
	set task_num "$argv[1]"
	set task_name "$argv[2..-1]"

	set filtered_task_name (string replace --all --regex '[ -/]+' '_' $task_name)
	set filtered_task_name (string replace --all --regex '(?<!^)([A-Z]+)' '_$1' $filtered_task_name) # to snake_case
	set filtered_task_name (string replace --all --regex '_+' '_' $filtered_task_name)
	set filtered_task_name (string lower $filtered_task_name)
	set task_dir ~/TFS/$task_num-$filtered_task_name/

	mkdir -pv $task_dir
	and pushd "$task_dir"
	and env PWD_AS_KB_ROOT=y tfs-set-ticket $argv
end

