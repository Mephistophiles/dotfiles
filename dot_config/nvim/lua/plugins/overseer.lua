return {
    'stevearc/overseer.nvim',
    keys = {
        { '<leader>ot', CMD 'OverseerToggle', desc = 'Overseer: Toggle' },
        { '<leader>or', CMD 'OverseerRun', desc = 'Overseer: Run' },
        { '<leader>ob', CMD 'OverseerBuild', desc = 'Overseer: Build' },
    },
    cmd = { 'OverseerRun', 'OverseerBuild', 'OverseerToggle' },
    config = function()
        require('overseer').setup {
            strategy = 'terminal',
        }
    end,
}
