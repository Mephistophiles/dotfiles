local relative_numbers_group = vim.api.nvim_create_augroup('ToggleRelativeNumber', { clear = true })

vim.opt.number = true -- Default number mode

local function relativeln(target)
    if vim.b.lnstatus == nil then
        vim.b.lnstatus = 'number'
    end

    if vim.b.lnstatus ~= 'nonumber' then
        if target == 'number' then
            vim.o.number = true
            vim.o.relativenumber = false
        else
            vim.o.number = true
            vim.o.relativenumber = true
        end
    else
        vim.o.number = false
    end
end

local function toggleln()
    if vim.b.lnstatus == nil then
        vim.b.lnstatus = 'number'
    end

    if vim.b.lnstatus == 'number' then
        vim.o.number = false
        vim.o.relativenumber = false
        vim.b.lnstatus = 'nonumber'
    else
        vim.o.number = true
        vim.o.relativenumber = true
        vim.b.lnstatus = 'number'
    end
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
    pattern = '*',
    group = relative_numbers_group,
    callback = function()
        if vim.o.number and vim.api.nvim_get_mode().mode ~= 'i' then
            relativeln 'relativenumber'
        end
    end,
})

vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
    pattern = '*',
    group = relative_numbers_group,
    callback = function()
        if vim.o.number then
            relativeln 'number'
            vim.cmd 'redraw'
        end
    end,
})

-- toggle show invisible symbols
vim.keymap.set({ 'n', 'i' }, '<F2>', function()
    toggleln()
end, { desc = 'Toggle numbers/relativenumbers' })
