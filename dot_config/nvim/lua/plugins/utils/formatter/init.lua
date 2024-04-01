local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

local IGNORELIST = require 'plugins.utils.formatter.ignorelist'

local M = {}

local format_file = function(bufnr)
    require('conform').format { bufnr = bufnr, lsp_fallback = true }
end

--- Attach formatter to the current buffer
---@param client vim.lsp.Client|nil
---@param bufnr  integer
function M.attach_formatter(client, bufnr)
    if not client or client.supports_method 'textDocument/formatting' then
        local toggle_formatting = function()
            if vim.b.format_on_save then
                vim.notify 'Disable formatting on save'
            else
                vim.notify 'Enable formatting on save'
            end
            vim.b.format_on_save = not vim.b.format_on_save
        end

        vim.keymap.set('n', '<C-f>', function()
            format_file(bufnr)
        end, { silent = true, buffer = true, desc = 'Format current document' })

        vim.keymap.set(
            'n',
            '<leader>mt',
            toggle_formatting,
            { desc = 'Formatter: toggle formatter in current document' }
        )

        vim.keymap.set('n', '<leader>mi', function()
            IGNORELIST.ignore_file(vim.api.nvim_buf_get_name(0))
            vim.b.disable_formatter = true
            vim.notify 'Permanently disable format on save'
        end, { desc = 'Formatter: permanently disable format for current file' })
        vim.keymap.set('n', '<leader>mu', function()
            IGNORELIST.unignore_file(vim.api.nvim_buf_get_name(0))
            vim.b.disable_formatter = false
            vim.notify 'Remove current file from the ignorelist'
        end, { desc = 'Formatter: remove current file from the ignorelist' })
        vim.keymap.set('n', '<leader>mc', function()
            local before = IGNORELIST.get()
            local after = IGNORELIST.gc_ignorelist(before)
            vim.notify(string.format('GC ignorelist: %d -> %d entries', #before, #after))
        end, { desc = 'Formatter: run garbage collector in ignorelist' })
        vim.keymap.set('n', '<leader>ml', function()
            require('plugins.utils.formatter.ui').toggle_quick_menu(IGNORELIST.get())
        end, { desc = 'Formatter: open ignorelistmenu' })

        vim.api.nvim_create_user_command('AutoFormatToggle', toggle_formatting, {})

        vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            desc = 'Format document on save',
            buffer = 0,
            callback = function(opts)
                if vim.b.format_on_save and not IGNORELIST.is_ignored_file(opts.file) then
                    format_file(opts.buffer)
                end
            end,
        })
    end
end

function M.on_menu_save(ignorelist)
    IGNORELIST.set(ignorelist)
end

return M
