return {
    'folke/flash.nvim',
    ---@type Flash.Config
    opts = { modes = { search = { enabled = false }, char = { enabled = false } } },
    keys = {
        {
            '<leader>w',
            function()
                require('flash').jump { search = { forward = true, wrap = false, multi_window = false } }
            end,
            desc = 'Flash: forward search',
        },
        {
            '<leader>b',
            function()
                require('flash').jump { search = { forward = false, wrap = false, multi_window = false } }
            end,
            desc = 'Flash: backward search',
        },
        {
            '<leader>W',
            function()
                require('flash').treesitter()
            end,
            desc = 'Flash Treesitter',
        },
    },
}
