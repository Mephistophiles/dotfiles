local qf_ns = vim.api.nvim_create_namespace 'QuickFix'

vim.api.nvim_create_user_command('QFToDiag', function()
    local diags_by_buf = {}

    vim.diagnostic.reset(qf_ns)

    for _, item in ipairs(vim.diagnostic.fromqflist(vim.fn.getqflist())) do
        if not diags_by_buf[item.bufnr] then
            diags_by_buf[item.bufnr] = {}
        end

        table.insert(diags_by_buf[item.bufnr], item)
    end

    for bufnr, items in pairs(diags_by_buf) do
        vim.diagnostic.set(qf_ns, bufnr, items)
    end
end, {})
