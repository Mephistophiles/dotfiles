return {
    'nvim-neotest/neotest',
    keys = {
        { '<leader>tr', CMD 'lua require("neotest").run.run()', desc = 'Neotest: run' },
        {
            '<leader>tf',
            CMD 'lua require("neotest").run.run(vim.fn.expand("%"))',
            desc = 'Neotest: run in current file',
        },
        {
            '<leader>ts',
            CMD 'lua require("neotest").run.stop()',
            desc = 'Neotest: stop',
        },
        { '<leader>tl', CMD 'lua require("neotest").run.run_last()', desc = 'Neotest: run last' },
        { '<leader>ts', CMD 'lua require("neotest").summary.toggle()', desc = 'Neotest: show summary' },
        {
            '<leader>to',
            CMD 'lua require("neotest").output.open({ enter = true, auto_close = true })',
            desc = 'Neotest: show test output',
        },
        {
            '<leader>tO',
            CMD 'lua require("neotest").output_panel.toggle()',
            desc = 'Neotest: show test output',
        },
    },
    dependencies = {
        'lawrence-laz/neotest-zig',
        'nvim-lua/plenary.nvim',
        'nvim-neotest/neotest-go',
        'nvim-neotest/neotest-python',
        'nvim-neotest/nvim-nio',
        'nvim-treesitter/nvim-treesitter',
    },
    config = function()
        require('neotest').setup {
            adapters = {
                require 'neotest-go',
                require 'neotest-python',
                require 'neotest-zig',
                require 'rustaceanvim.neotest',
            },
        }
    end,
}
