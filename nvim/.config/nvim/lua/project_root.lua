local group = vim.api.nvim_create_augroup('ProjectRoot', { clear = true })

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufFilePost' }, {
    group = group,
    callback = function(args)
        local name = vim.api.nvim_buf_get_name(args.buf)
        if vim.bo[args.buf].buftype ~= '' or name == '' or name:match '^%a[%w+.-]*://'
            or vim.fn.isdirectory(name) == 1
        then
            return
        end

        local root = vim.fs.root(args.buf, { '.git', '.root' })
        vim.api.nvim_buf_call(args.buf, function()
            if root then
                vim.cmd.bcd(root)
            elseif vim.b.project_root then
                vim.cmd.bcd { bang = true }
            end
            vim.b.project_root = root
        end)
    end,
})
