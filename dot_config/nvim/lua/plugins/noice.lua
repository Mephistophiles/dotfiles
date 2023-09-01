return {
    'folke/noice.nvim',
    config = function()
        vim.keymap.set({ 'n', 'i', 's' }, '<c-f>', function()
            if not require('noice.lsp').scroll(4) then
                return '<c-f>'
            end
        end, { silent = true, expr = true })

        vim.keymap.set({ 'n', 'i', 's' }, '<c-d>', function()
            if not require('noice.lsp').scroll(-4) then
                return '<c-d>'
            end
        end, { silent = true, expr = true })
        require('noice').setup {
            cmdline = {
                view = 'cmdline',
            },
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                    ['cmp.entry.get_documentation'] = true,
                },
                hover = {
                    enabled = true,
                },
                signature = {
                    enabled = true,
                },
                documentation = {},
            },
            -- you can enable a preset for easier configuration
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = false, -- position the cmdline and popupmenu together
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
        }
    end,
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        'MunifTanjim/nui.nvim',
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        'rcarriga/nvim-notify',
    },
}
