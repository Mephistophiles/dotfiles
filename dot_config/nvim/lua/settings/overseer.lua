local M = {}

function M.setup()
    vim.keymap.set('n', '<leader>ot', CMD 'OverseerToggle', { desc = 'Overseer: Toggle' })
    vim.keymap.set('n', '<leader>or', CMD 'OverseerRun', { desc = 'Overseer: Run' })
    vim.keymap.set('n', '<leader>ob', CMD 'OverseerBuild', { desc = 'Overseer: Build' })
end

function M.config()
    require('overseer').setup {
        strategy = 'terminal',
    }
end

return M
