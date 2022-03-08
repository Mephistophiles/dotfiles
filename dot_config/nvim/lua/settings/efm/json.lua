local jq_args = {'jq', '--indent', '4'}

if vim.b.formatter_sort_keys then table.insert(jq_args, '--sort-keys') end

return {formatCommand = table.concat(jq_args, ' '), formatStdin = true}
