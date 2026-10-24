local IGNORELIST = require 'formatter.ignorelist'

local M = {}

local format_file = function(bufnr)
    require('plugin_usage').record('conform.nvim', 'format', 'manual')
    require('conform').format { bufnr = bufnr }
end

---@param bufnr integer
---@return conform.FormatOpts|nil
function M.format_on_save(bufnr)
    if not vim.b[bufnr].format_on_save or vim.b[bufnr].bigfile
        or IGNORELIST.is_ignored_file(vim.api.nvim_buf_get_name(bufnr))
    then
        return nil
    end
    require('plugin_usage').record('conform.nvim', 'format on save', 'automatic')
    return { timeout_ms = 1000 }
end

--- Attach formatter to the current buffer
---@param client vim.lsp.Client|nil
---@param bufnr  integer
function M.attach_formatter(client, bufnr)
    if bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end
    if not client or client:supports_method(vim.lsp.protocol.Methods.textDocument_formatting) then
        -- Install Conform's save handler before this buffer's first write.
        require 'conform'

        local toggle_formatting = function()
            if vim.b.format_on_save then
                vim.notify 'Disable formatting on save'
            else
                vim.notify 'Enable formatting on save'
            end
            vim.b.format_on_save = not vim.b.format_on_save
        end

        vim.keymap.set({ 'n', 'v' }, '<C-f>', function()
            format_file(bufnr)
        end, { silent = true, buf = bufnr, desc = 'Format current document' })

        vim.keymap.set(
            'n',
            '<leader>mt',
            toggle_formatting,
            { desc = 'Formatter: toggle formatter in current document' }
        )

        vim.keymap.set('n', '<leader>mi', function()
            IGNORELIST.ignore_file(vim.api.nvim_buf_get_name(0))
            vim.notify 'Permanently disable format on save'
        end, { desc = 'Formatter: permanently disable format for current file' })
        vim.keymap.set('n', '<leader>mu', function()
            IGNORELIST.unignore_file(vim.api.nvim_buf_get_name(0))
            vim.notify 'Remove current file from the ignorelist'
        end, { desc = 'Formatter: remove current file from the ignorelist' })
        vim.keymap.set('n', '<leader>mc', function()
            local before = IGNORELIST.get()
            local after = IGNORELIST.gc_ignorelist(before)
            vim.notify(string.format('GC ignorelist: %d -> %d entries', #before, #after))
        end, { desc = 'Formatter: run garbage collector in ignorelist' })
        vim.keymap.set('n', '<leader>ml', function()
            require('formatter.ui').toggle_quick_menu(IGNORELIST.get())
        end, { desc = 'Formatter: open ignorelistmenu' })

        vim.api.nvim_create_user_command('AutoFormatToggle', toggle_formatting, {})
    end
end

function M.on_menu_save(ignorelist)
    IGNORELIST.set(ignorelist)
end

return M
