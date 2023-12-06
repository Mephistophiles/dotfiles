vim.g.mapleader = ' '

local function paste_git_signoff()
    local username = io.popen('git config user.name', 'r'):read '*l'
    local email = io.popen('git config user.email', 'r'):read '*l'

    vim.api.nvim_put({ 'Signed-off-by: ' .. username .. ' <' .. email .. '>' }, 'c', false, true)

    return true
end

-- folding
vim.keymap.set('n', '<tab>', function()
    local current_level = vim.fn.foldlevel '.'

    if current_level > 0 then
        vim.api.nvim_input 'za'
    else
        vim.api.nvim_input '<tab>'
    end
end, { desc = 'Toggle fold' })

-- toggle spelling
vim.keymap.set('n', '<F7>', [[:set spell!<CR>]], { desc = 'Toggle spelling' })

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

-- tab/buffer/quickfix
vim.keymap.set('n', ']t', CMD 'tabnext', { desc = 'Tabs: goto next tab' })
vim.keymap.set('n', '[t', CMD 'tabprev', { desc = 'Tabs: goto previous tab' })

vim.keymap.set('n', ']b', CMD 'bnext', { desc = 'Buffers: goto next buffer' })
vim.keymap.set('n', '[b', CMD 'bprev', { desc = 'Buffers: goto previous buffer' })

vim.keymap.set('n', ']q', CMD 'cnext', { desc = 'QuickFix: goto next error' })
vim.keymap.set('n', '[q', CMD 'cprev', { desc = 'QuickFix: goto previous error' })

vim.keymap.set('i', '<C-c>', '<Esc>', { desc = 'Handle C-c as Esc, otherwise some operations can be aborted' })

require('highlight').setup()

vim.keymap.set('n', '<CR>', function()
    require('highlight').highlight_usages(0)
end, { desc = 'Highlight word under cursor' })
table.insert(MAP_CLEANUPS, CMD 'lua require("highlight").clear_usage_highlights(0)')
