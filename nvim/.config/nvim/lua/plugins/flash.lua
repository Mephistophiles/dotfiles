return {
    'folke/flash.nvim',
    ---@type Flash.Config
    opts = { modes = { search = { enabled = false }, char = { enabled = false } } },
    keys = {
        {
            '<leader>f',
            mode = { 'n', 'x', 'o' },
            function()
                require('flash').jump()
            end,
            desc = 'Flash: motion',
        },
        {
            '<leader>v',
            mode = { 'n', 'x', 'o' },
            function()
                require('flash').treesitter()
            end,
            desc = 'Flash: Treesitter',
        },
        {
            'r',
            mode = 'o',
            function()
                require('flash').remote()
            end,
            desc = 'Flash: remote motion',
        },
        {
            'R',
            mode = { 'o', 'x' },
            function()
                require('flash').treesitter_search()
            end,
            desc = 'Flash: treesitter search',
        },
        {
            '<C-/>',
            mode = { 'c' },
            function()
                require('flash').toggle()
            end,
            desc = 'Flash: toggle flash search',
        },
    },
}
