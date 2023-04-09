return {
    'folke/noice.nvim',
    config = {
        cmdline = {
            -- view = 'cmdline',
        },
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                ['vim.lsp.util.stylize_markdown'] = true,
                ['cmp.entry.get_documentation'] = true,
            },
        },
        -- you can enable a preset for easier configuration
        presets = {
            bottom_search = true, -- use a classic bottom cmdline for search
            command_palette = true, -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false, -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false, -- add a border to hover docs and signature help
        },

        routes = {
            {
                filter = {
                    event = 'msg_show',
                    kind = '',
                    find = 'written',
                },
                opts = { skip = true },
            },
        },
    },
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        'MunifTanjim/nui.nvim',
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        {
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
                        'Stacktrace in notifications was '
                            .. (vim.g.nvim_notify_stack_trace and 'enabled' or 'disabled'),
                        vim.log.levels.INFO
                    )
                end, { desc = 'Notifications: toggle stacktrace from warn and above' })
            end,
        },
    },
}
