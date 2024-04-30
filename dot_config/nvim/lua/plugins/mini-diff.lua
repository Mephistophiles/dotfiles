return {
    'echasnovski/mini.diff',
    varsion = false,
    event = 'VeryLazy',
    keys = {
        { '<leader>md', CMD 'lua require("mini.diff").toggle_overlay()', desc = 'Mini.Diff: toggle overlay' },
    },
    config = function()
        local diff = require 'mini.diff'
        diff.setup { source = diff.gen_source.save() }
    end,
}
