vim.g.mapleader = ' '

-- Toggle paste
vim.o.pastetoggle = '<F6>'

local function number_toggle()
    if vim.o.relativenumber then
        vim.notify 'Disable relative numbers'
        vim.o.relativenumber = false
    else
        vim.notify 'Enable relative numbers'
        vim.o.relativenumber = true
    end
end

local function swap_list_chars()
    if not vim.g.listchars_mode then
        vim.g.listchars_mode = 1
    end

    if vim.g.listchars_mode == 0 then
        vim.o.list = true
        vim.g.listchars_mode = 1
        vim.notify 'Enable list mode'
    elseif vim.g.listchars_mode == 1 then
        vim.opt.listchars:append { space = '·', eol = '$' }
        vim.g.listchars_mode = 2
        vim.notify 'Enable verbose list mode'
    elseif vim.g.listchars_mode == 2 then
        vim.opt.listchars:remove { 'space', 'eol' }
        vim.o.list = false
        vim.g.listchars_mode = 0
        vim.notify 'Disable list mode'
    end
end

local function paste_git_signoff()
    local username = io.popen('git config user.name', 'r'):read '*l'
    local email = io.popen('git config user.email', 'r'):read '*l'

    vim.api.nvim_put({ 'Signed-off-by: ' .. username .. ' <' .. email .. '>' }, 'c', false, true)

    return true
end

-- toggle show invisible symbols
vim.keymap.set('n', '<F2>', function()
    number_toggle()
end)
vim.keymap.set('i', '<F2>', function()
    number_toggle()
end)

vim.keymap.set('n', '<F4>', function()
    swap_list_chars()
end)

-- toggle spelling
vim.keymap.set('n', '<F7>', [[:set spell!<CR>]])

-- Back search for f F t T
vim.keymap.set('n', [[\]], ',')

-- paste signoff
vim.keymap.set('n', '<F8>', function()
    paste_git_signoff()
end)
vim.keymap.set('i', '<F8>', function()
    paste_git_signoff()
end)

-- command mode helpers
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-p>', '<Up>')
vim.keymap.set('c', '<C-n>', '<Down>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-f>', '<Right>')

-- map Home to buffernext, End bufferprev
vim.keymap.set('n', '<Home>', ':bn')
vim.keymap.set('n', '<End>', ':bp')

-- very magic search by default
vim.keymap.set('n', [[?]], [[?\v]])
vim.keymap.set('n', [[/]], [[/\v]])
vim.keymap.set('c', [[%s/]], [[%sm/]])

-- Suppress command mistakes
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('WQ', 'wq', {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('WQA', 'wqa', {})
vim.api.nvim_create_user_command('WQa', 'wqa', {})
vim.api.nvim_create_user_command('Wqa', 'wqa', {})
vim.api.nvim_create_user_command('Q', 'q', {})

-- folding
vim.keymap.set('n', '<tab>', function()
    local current_level = vim.fn.foldlevel '.'

    if current_level > 0 then
        vim.api.nvim_input 'za'
    else
        vim.api.nvim_input '<tab>'
    end
end)

-- Better usage
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('v', 'J', [[:m '>+1<CR>gv=gv]])
vim.keymap.set('v', 'K', [[:m '<-2<CR>gv=gv]])

-- replace paste without save in registers
vim.keymap.set('v', '<leader>p', '"_dP')

-- copy in clipboard
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', 'gg"+yG')

-- workarounds
-- inoremap <C-c> <Esc>
vim.keymap.set('i', '<C-c>', '<Esc>')

-- resize
vim.keymap.set('n', '<C-w>K', ':resize -5<CR>')
vim.keymap.set('n', '<C-w>J', ':resize +5<CR>')
vim.keymap.set('n', '<C-w>H', ':vertical resize -5<CR>')
vim.keymap.set('n', '<C-w>L', ':vertical resize +5<CR>')
