local group = vim.api.nvim_create_augroup('ProjectRoot', { clear = true })

vim.api.nvim_create_autocmd({ 'VimEnter', 'BufEnter' }, {
    pattern = '*',
    group = group,
    callback = function()
        local project_root = vim.fs.root(0, { '.git', '.root' })

        if project_root then
            vim.api.nvim_set_current_dir(project_root)
        end
    end,
})
