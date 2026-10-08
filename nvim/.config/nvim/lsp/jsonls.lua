local exe_resolve = function(name)
    if vim.fn.executable(name) == 1 then
        return name
    end
end

return {
    cmd = { exe_resolve 'vscode-json-languageserver' or 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    root_markers = { '.git' },
}
