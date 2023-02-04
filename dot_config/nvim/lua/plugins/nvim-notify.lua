return { -- A fancy, configurable, notification manager for NeoVim
    'rcarriga/nvim-notify',
    config = function()
        local notify_fn = require 'notify'
        vim.notify = setmetatable({}, {
            __call = function(_, msg, level, opts)
                if vim.g.nvim_notify_stack_trace and level and level >= vim.log.levels.WARN then
                    msg = msg .. '\n' .. debug.traceback('Trace', 2)
                end

                notify_fn(msg, level, opts)
            end,
            __index = function(_, key)
                return notify_fn[key]
            end,
        })

        vim.keymap.set('n', '<F3>', function()
            vim.g.nvim_notify_stack_trace = not vim.g.nvim_notify_stack_trace
            vim.notify(
                'Stacktrace in notifications was ' .. (vim.g.nvim_notify_stack_trace and 'enabled' or 'disabled'),
                vim.log.levels.INFO
            )
        end, { desc = 'Notifications: toggle stacktrace from warn and above' })
    end,
}
