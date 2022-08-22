vim.g.mapleader = ' '

-- Toggle paste
vim.o.pastetoggle = '<F6>'

local function paste_git_signoff()
    local username = io.popen('git config user.name', 'r'):read '*l'
    local email = io.popen('git config user.email', 'r'):read '*l'

    vim.api.nvim_put({ 'Signed-off-by: ' .. username .. ' <' .. email .. '>' }, 'c', false, true)

    return true
end

-- toggle spelling
vim.keymap.set('n', '<F7>', [[:set spell!<CR>]], { desc = 'Toggle spelling' })

-- Back search for f F t T
vim.keymap.set('n', [[\]], ',', { desc = 'Back search for f/F t/T' })

-- paste signoff
vim.keymap.set({ 'n', 'i' }, '<F8>', function()
    paste_git_signoff()
end, { desc = 'Paste Signed-off-by' })

-- command mode helpers
vim.keymap.set('c', '<C-a>', '<Home>', { desc = 'Goto to start of line' })
vim.keymap.set('c', '<C-e>', '<End>', { desc = 'Goto to end of line' })
vim.keymap.set('c', '<C-p>', '<Up>', { desc = 'Select previous command' })
vim.keymap.set('c', '<C-n>', '<Down>', { desc = 'Select next command' })
vim.keymap.set('c', '<C-b>', '<Left>', { desc = 'Move cursor left' })
vim.keymap.set('c', '<C-f>', '<Right>', { desc = 'Move cursor right' })

-- map Home to buffernext, End bufferprev
vim.keymap.set('n', '<Home>', ':bnext', { desc = 'Select next buffer' })
vim.keymap.set('n', '<End>', ':bprev', { desc = 'Select previous buffer' })

-- very magic search by default
vim.keymap.set('n', [[?]], [[?\v]], { desc = 'Backward search with magic mode' })
vim.keymap.set('n', [[/]], [[/\v]], { desc = 'Search with magic mode' })
vim.keymap.set('c', [[%s/]], [[%sm/]], { desc = 'Search with magic mode' })

-- Suppress command mistakes
vim.api.nvim_create_user_command('W', 'w', { desc = 'Fix typo :W -> :w' })
vim.api.nvim_create_user_command('WQ', 'wq', { desc = 'Fix typo :WQ -> :wq' })
vim.api.nvim_create_user_command('Wq', 'wq', { desc = 'Fix typo :Wq -> :wq' })
vim.api.nvim_create_user_command('WQA', 'wqa', { desc = 'Fix typo :WQA -> :wqa' })
vim.api.nvim_create_user_command('WQa', 'wqa', { desc = 'Fix typo :WQa -> :wqa' })
vim.api.nvim_create_user_command('Wqa', 'wqa', { desc = 'Fix typo :Wqa -> :wqa' })
vim.api.nvim_create_user_command('Q', 'q', { desc = 'Fix typo :Q -> :q' })

-- folding
vim.keymap.set('n', '<tab>', function()
    local current_level = vim.fn.foldlevel '.'

    if current_level > 0 then
        vim.api.nvim_input 'za'
    else
        vim.api.nvim_input '<tab>'
    end
end, { desc = 'Toggle fold' })

-- Better usage
vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank to end of line' })
vim.keymap.set('n', 'n', 'nzz', { desc = 'Goto to next search with possible unfold' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Goto to previous search with possible unfold' })

-- copy in clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Copy to clipboard' })
vim.keymap.set('n', '<leader>Y', 'gg"+yG', { desc = 'Copy to clipboard all file' })

-- workarounds
-- inoremap <C-c> <Esc>
vim.keymap.set('i', '<C-c>', '<Esc>', { desc = 'Emulate <ESC> by Ctrl+C' })

-- resize
vim.keymap.set('n', '<C-w>K', ':resize -5<CR>', { desc = 'Decrease horizontal size of split' })
vim.keymap.set('n', '<C-w>J', ':resize +5<CR>', { desc = 'Increase horizontal size of split' })
vim.keymap.set('n', '<C-w>H', ':vertical resize -5<CR>', { desc = 'Decrease vertical size of split' })
vim.keymap.set('n', '<C-w>L', ':vertical resize +5<CR>', { desc = 'Increase vertical size of split' })
