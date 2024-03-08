return { -- Quick change harpooned buffers
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = true,
    opts = {},
    keys = {
        {
            '<Leader>`',
            function()
                local harpoon = require 'harpoon'

                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = 'Harpoon: show menu',
        },
        {
            '<Leader>h',
            function()
                local harpoon = require 'harpoon'

                harpoon:list():append()
            end,
            desc = 'Harpoon: toogle mark',
        },
        {
            '<Leader>1',
            function()
                local harpoon = require 'harpoon'

                harpoon:list():select(1)
            end,
            desc = 'Harpoon: select 1 mark',
        },
        {
            '<Leader>2',
            function()
                local harpoon = require 'harpoon'

                harpoon:list():select(2)
            end,
            desc = 'Harpoon: select 2 mark',
        },
        {
            '<Leader>3',
            function()
                local harpoon = require 'harpoon'

                harpoon:list():select(3)
            end,
            desc = 'Harpoon: select 3 mark',
        },
        {
            '<Leader>4',
            function()
                local harpoon = require 'harpoon'

                harpoon:list():select(4)
            end,
            desc = 'Harpoon: select 4 mark',
        },
        {
            '<Leader>5',
            function()
                local harpoon = require 'harpoon'

                harpoon:list():select(5)
            end,
            desc = 'Harpoon: select 5 mark',
        },
        {
            '<Leader>6',
            function()
                local harpoon = require 'harpoon'

                harpoon:list():select(6)
            end,
            desc = 'Harpoon: select 6 mark',
        },
        {
            '<C-p>',
            function()
                local harpoon = require 'harpoon'

                harpoon:list():prev()
            end,
            desc = 'Harpoon: Toggle previous buffers stored within list',
        },
        {
            '<C-n>',
            function()
                local harpoon = require 'harpoon'

                harpoon:list():next()
            end,
            desc = 'Harpoon: Toggle next buffers stored within list',
        },
    },
}
