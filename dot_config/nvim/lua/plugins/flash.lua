return {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
        {
            '<leader>w',
            mode = { 'n', 'x', 'o' },
            function()
                require('flash').jump { search = { forward = true, wrap = false, multi_window = false } }
            end,
            desc = 'Flash',
        },
        {
            '<leader>b',
            mode = { 'n', 'x', 'o' },
            function()
                require('flash').jump { search = { forward = false, wrap = false, multi_window = false } }
            end,
            desc = 'Flash',
        },
        {
            '<leader>W',
            mode = { 'n', 'o', 'x' },
            function()
                require('flash').treesitter()
            end,
            desc = 'Flash Treesitter',
        },
        {
            '<leader>r',
            mode = 'o',
            function()
                require('flash').remote()
            end,
            desc = 'Remote Flash',
        },
    },
}
