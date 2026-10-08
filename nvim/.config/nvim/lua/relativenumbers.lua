local group = vim.api.nvim_create_augroup('ToggleRelativeNumber', { clear = true })

vim.opt.number = true

local function update(relative)
    if vim.w.lnstatus == 'nonumber' then
        vim.wo.number = false
    elseif vim.w.lnstatus == 'number' and vim.bo.buftype == '' then
        -- Revisiting a buffer restores its old window options; keep the toggle
        -- consistent across ordinary buffers without enabling numbers in terminals.
        vim.wo.number = true
    end
    vim.wo.relativenumber = vim.wo.number and relative
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
    group = group,
    callback = function()
        update(vim.api.nvim_get_mode().mode:sub(1, 1) ~= 'i')
    end,
})

vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
    group = group,
    callback = function()
        update(false)
    end,
})

vim.keymap.set({ 'n', 'i' }, '<F2>', function()
    local enabled = not vim.wo.number
    vim.w.lnstatus = enabled and 'number' or 'nonumber'
    vim.wo.number = enabled
    vim.wo.relativenumber = enabled and vim.api.nvim_get_mode().mode:sub(1, 1) ~= 'i'
end, { desc = 'Toggle numbers/relativenumbers' })
