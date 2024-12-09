return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        rename = { enabled = true },
        term = { enabled = true },
        words = { enabled = true },
    },
    keys = {
        {
            '<leader>ps',
            function()
                Snacks.profiler.scratch()
            end,
            desc = 'Snacks: open a scratch buffer with the profiler picker options',
        },
        {
            '<leader>ph',
            function()
                Snacks.profiler.highlight()
            end,
            desc = 'Snacks: toggle the profiler highlights',
        },
        {
            '<F12>',
            function()
                Snacks.terminal()
            end,
            desc = 'Snacks: toggle term',
        },
        {
            '<leader>-',
            function()
                Snacks.scratch()
            end,
            desc = 'Snacks: toggle Scratch Buffer',
        },
        {
            '<leader>_',
            function()
                Snacks.scratch.select()
            end,
            desc = 'Snacks: select Scratch Buffer',
        },
    },
    config = function()
        vim.notify = Snacks.notifier
        table.insert(MAP_CLEANUPS, CMD 'lua Snacks.notifier.hide()')
    end,
}
