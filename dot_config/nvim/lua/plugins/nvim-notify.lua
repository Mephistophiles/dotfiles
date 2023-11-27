return {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function()
        vim.notify = require 'notify'

        table.insert(MAP_CLEANUPS, CMD 'lua·require("notify").dissmiss()')
    end,
}
