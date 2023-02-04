return { -- Clean window maximizing, terminal toggling, window/tmux pane movements and more!
    'declancm/windex.nvim',
    keys = {
        {
            '<leader>z',
            CMD "lua require('windex').toggle_nvim_maximize()",
            desc = 'Windex: Toggle maximizing the current window',
        },
    },
    config = function()
        require('windex').setup {
            default_keymaps = false,
        }
    end,
}
