local M = {}

function M.setup() end

function M.config()
    require('textcase').setup {}
    require('telescope').load_extension 'textcase'
    vim.api.nvim_set_keymap('n', 'ga.', '<cmd>TextCaseOpenTelescope<CR>', { desc = 'text-case: convert case' })
    vim.api.nvim_set_keymap('v', 'ga.', '<cmd>TextCaseOpenTelescope<CR>', { desc = 'text-case: convert case' })
end

return M
