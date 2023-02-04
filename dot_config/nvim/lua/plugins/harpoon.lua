return { -- Quick change harpooned buffers
    'ThePrimeagen/harpoon',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim' },
    keys = {
        {
            '<Leader>`',
            function()
                require('harpoon.ui').toggle_quick_menu()
            end,
            desc = 'Harpoon: show menu',
        },
        {
            '<Leader>h',
            function()
                require('harpoon.mark').add_file()
            end,
            desc = 'Harpoon: toogle mark',
        },
        {
            '<Leader>1',
            function()
                require('harpoon.ui').nav_file(1)
            end,
            desc = 'Harpoon: select 1 mark',
        },
        {
            '<Leader>2',
            function()
                require('harpoon.ui').nav_file(2)
            end,
            desc = 'Harpoon: select 2 mark',
        },
        {
            '<Leader>3',
            function()
                require('harpoon.ui').nav_file(3)
            end,
            desc = 'Harpoon: select 3 mark',
        },
        {
            '<Leader>4',
            function()
                require('harpoon.ui').nav_file(4)
            end,
            desc = 'Harpoon: select 4 mark',
        },
        {
            '<Leader>5',
            function()
                require('harpoon.ui').nav_file(5)
            end,
            desc = 'Harpoon: select 5 mark',
        },
        {
            '<Leader>6',
            function()
                require('harpoon.ui').nav_file(6)
            end,
            desc = 'Harpoon: select 6 mark',
        },
    },
}
