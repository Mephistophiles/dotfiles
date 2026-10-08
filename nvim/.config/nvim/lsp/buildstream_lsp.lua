return {
    cmd = { 'buildstream-lsp' },
    filetypes = { 'yaml' },
    get_language_id = function()
        return 'bst'
    end,
    root_dir = function(bufnr, on_dir)
        if vim.api.nvim_buf_get_name(bufnr):match '%.bst$' then
            local root = vim.fs.root(bufnr, { 'project.conf' })
            if root then
                on_dir(root)
            end
        end
    end,
}
