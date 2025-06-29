vim.g.mapleader = ' '
vim.g.maplocalleader = vim.g.mapleader

-- toggle spelling
vim.keymap.set('n', '<F7>', [[:set spell!<CR>]], { desc = 'Toggle spelling' })

-- command mode helpers
vim.keymap.set('c', '<C-a>', '<Home>', { desc = 'Goto to start of line' })
vim.keymap.set('c', '<C-e>', '<End>', { desc = 'Goto to end of line' })
vim.keymap.set('c', '<C-p>', '<Up>', { desc = 'Select previous command' })
vim.keymap.set('c', '<C-n>', '<Down>', { desc = 'Select next command' })
vim.keymap.set('c', '<C-b>', '<Left>', { desc = 'Move cursor left' })
vim.keymap.set('c', '<C-f>', '<Right>', { desc = 'Move cursor right' })

-- Suppress command mistakes
vim.api.nvim_create_user_command('W', 'w', { desc = 'Fix typo :W -> :w' })
vim.api.nvim_create_user_command('WQ', 'wq', { desc = 'Fix typo :WQ -> :wq' })
vim.api.nvim_create_user_command('Wq', 'wq', { desc = 'Fix typo :Wq -> :wq' })
vim.api.nvim_create_user_command('WQA', 'wqa', { desc = 'Fix typo :WQA -> :wqa' })
vim.api.nvim_create_user_command('WQa', 'wqa', { desc = 'Fix typo :WQa -> :wqa' })
vim.api.nvim_create_user_command('Wqa', 'wqa', { desc = 'Fix typo :Wqa -> :wqa' })
vim.api.nvim_create_user_command('Q', 'q', { desc = 'Fix typo :Q -> :q' })

-- Better usage
vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank to end of line' })
vim.keymap.set('n', 'n', 'nzz', { desc = 'Goto to next search with possible unfold' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Goto to previous search with possible unfold' })

-- copy in clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Copy to clipboard' })
vim.keymap.set('n', '<leader>Y', '"+y$', { desc = 'Copy to clipboard all file' })

vim.keymap.set('i', '<C-c>', '<Esc>', { desc = 'Handle C-c as Esc, otherwise some operations can be aborted' })

-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('v', '<C-n>', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', '<C-p>', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })
vim.keymap.set('n', '<C-n>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<C-p>', ':m .-2<CR>==', { desc = 'Move line up' })

vim.keymap.set('n', '<CR>', function()
    local word = [[\<]] .. vim.fn.expand '<cword>' .. [[\>]]
    vim.fn.setreg('/', word)
    vim.opt.hlsearch = true
end, { desc = 'Highlight word under cursor' })

-- Cleanup all selection
vim.keymap.set(
    'n',
    '<esc>',
    CMD 'nohlsearch' .. CMD 'call clearmatches()',
    { desc = 'Clean all notifications/selections' }
)
