return { -- Treesitter based structural search and replace plugin for Neovim.
    'cshuaimin/ssr.nvim',
    keys = {
        {
            '<leader>sr',
            function()
                require('ssr').open()
            end,
            mode = { 'n', 'x' },
            desc = 'SSR: Open popup',
        },
    },
    config = function()
        require('ssr').setup {
            min_width = 50,
            min_height = 5,
            keymaps = {
                close = 'q',
                next_match = 'n',
                prev_match = 'N',
                replace_all = '<leader><cr>',
            },
        }
    end,
}
