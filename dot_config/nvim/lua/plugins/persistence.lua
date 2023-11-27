return {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    opts = {
        -- add any custom options here
    },
    config = function()
        vim.keymap.set(
            'n',
            '<leader>gs',
            CMD 'lua require("persistence").load()',
            { desc = 'Persistence: restore the session from the current directory' }
        )
        vim.keymap.set(
            'n',
            '<leader>gl',
            CMD 'lua require("persistence").load({ last = true })',
            { desc = 'Persistence: restore the last session' }
        )
        vim.keymap.set(
            'n',
            '<leader>gl',
            CMD 'lua require("persistence").stop()',
            { desc = 'Persistence: stop Persistence => session wont be saved on exit' }
        )
    end,
}
