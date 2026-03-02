return {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function()
        local notify = require 'notify'
        notify.setup {}

        vim.notify = function(...)
            notify.notify(...)
        end
    end,
}
