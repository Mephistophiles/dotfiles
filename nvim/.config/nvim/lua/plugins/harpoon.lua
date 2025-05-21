return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    keys = {
        {
            '<leader>a',
            function()
                require('harpoon'):list():add()
            end,
            desc = 'Harpoon: add file',
        },
        {
            '<C-e>',
            function()
                local harpoon = require 'harpoon'
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = 'Harpoon: open quick menu',
        },
        {
            '<C-1>',
            function()
                require('harpoon'):list():select(1)
            end,
            desc = 'Harpoon: open 1 file',
        },
        {
            '<C-2>',
            function()
                require('harpoon'):list():select(2)
            end,
            desc = 'Harpoon: open 2 file',
        },
        {
            '<C-3>',
            function()
                require('harpoon'):list():select(3)
            end,
            desc = 'Harpoon: open 3 file',
        },
        {
            '<C-4>',
            function()
                require('harpoon'):list():select(4)
            end,
            desc = 'Harpoon: open 4 file',
        },
        {
            '<C-S-P>',
            function()
                require('harpoon'):list():prev()
            end,
            desc = 'Harpoon: open prev file',
        },
        {
            '<C-S-N>',
            function()
                require('harpoon'):list():next()
            end,
            desc = 'Harpoon: open next file',
        },
    },
    opts = {},
    dependencies = { 'nvim-lua/plenary.nvim' },
}
