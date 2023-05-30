local M = {}

local function smart_goto(fn)
    for _, severity in ipairs {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
        vim.diagnostic.severity.INFO,
        vim.diagnostic.severity.HINT,
    } do
        local diagnostic = vim.diagnostic.get(0, { severity = severity })

        if #diagnostic > 0 then
            fn(severity)
            break
        end
    end
end

local function smart_goto_next()
    smart_goto(function(severity)
        vim.diagnostic.goto_next {
            severity = severity,
        }
    end)
end

local function smart_goto_prev()
    smart_goto(function(severity)
        vim.diagnostic.goto_prev {
            severity = severity,
        }
    end)
end

local function keymap(key, cmd, user_opts)
    local default_opts = { remap = true, buffer = true }
    local opts = vim.tbl_extend('force', default_opts, user_opts or {})

    vim.keymap.set('n', key, cmd, opts)
end

function M.key_bindings(client)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    keymap('gD', CMD 'Lspsaga goto_declaration', { desc = 'LSP: goto declaration' })
    keymap('gd', CMD 'Lspsaga goto_definition', { desc = 'LSP: goto definition' })
    keymap('<leader>D', CMD 'Lspsaga peek_type_definition', { desc = 'LSP: goto type definition' })
    keymap('gr', CMD 'Lspsaga lsp_finder', { desc = 'LSP: show the definition, reference and implementation' })
    keymap('<leader>ca', CMD 'Lspsaga code_action', { desc = 'LSP: show code actions' })

    -- Call hierarchy
    keymap('<Leader>ci', '<cmd>Lspsaga incoming_calls<CR>')
    keymap('<Leader>co', '<cmd>Lspsaga outgoing_calls<CR>')

    keymap('K', vim.lsp.buf.hover, { desc = 'LSP: display hover information about the symbol under ther cursor' })
    keymap('<leader>rn', CMD 'Lspsaga rename', { desc = 'LSP: renames all references to the symbol under the cursor' })
    -- vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, nil, "buffer")
    keymap('<leader>d', CMD 'Lspsaga show_line_diagnostics', { desc = 'LSP: Show diagnostic info' })
    keymap(
        '[D',
        CMD 'Lspsaga diagnostic_jump_prev',
        { desc = 'LSP: move to the previous diagnostic (whole severities)' }
    )
    keymap(']D', CMD 'Lspsaga diagnostic_jump_next', { desc = 'LSP: move to the next diagnostic (whole severities)' })
    keymap('[d', function()
        smart_goto_prev()
    end, { desc = 'LSP: move to the previous diagnostic' })
    keymap(']d', function()
        smart_goto_next()
    end, { desc = 'LSP: move to the next diagnostic' })
    keymap('<leader>q', function()
        vim.diagnostic.setloclist()
    end, { desc = 'LSP: add buffer diagnostics to the location list' })

    if client.supports_method 'document/Formatting' then
        vim.keymap.set(
            'n',
            '<leader>lf',
            vim.lsp.buf.format,
            { buffer = true, desc = 'LSP: format document by lsp engine' }
        )
    end

    if client.supports_method 'textDocument/codeLens' then
        vim.keymap.set(
            'n',
            '<leader>lr',
            vim.lsp.codelens.run,
            { buffer = true, desc = 'LSP: run code lens in the current line' }
        )
    end
end

local custom_init = function(client)
    client.config.flags = client.config.flags or {}
    client.config.flags.allow_incremental_sync = true
end

local filetype_attach = setmetatable({ go = function() end, rust = function() end }, {
    __index = function()
        return function() end
    end,
})

local custom_attach = function(client, bufnr)
    local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

    M.key_bindings(client)

    vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Set autocommands conditional on server_capabilities
    if client.supports_method 'textDocument/documentHighlight' then
        local lsp_document_highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
        vim.api.nvim_create_autocmd('CursorHold', {
            group = lsp_document_highlight_group,
            buffer = 0,
            desc = 'Document highlight',
            callback = function()
                vim.lsp.buf.document_highlight()
            end,
        })

        vim.api.nvim_create_autocmd('CursorMoved', {
            group = lsp_document_highlight_group,
            buffer = 0,
            desc = 'Document clear references',
            callback = function()
                vim.lsp.buf.clear_references()
            end,
        })
    end

    if client.supports_method 'textDocument/codeLens' then
        local lsp_document_codelens_group = vim.api.nvim_create_augroup('lsp_document_codelens', { clear = false })
        vim.api.nvim_create_autocmd('BufEnter', {
            group = lsp_document_codelens_group,
            buffer = 0,
            once = true,
            desc = 'refresh on enter',
            callback = function()
                require('vim.lsp.codelens').refresh()
            end,
        })

        vim.api.nvim_create_autocmd({ 'BufWritePost', 'CursorHold' }, {
            group = lsp_document_codelens_group,
            buffer = 0,
            desc = 'Refresh references',
            callback = function()
                require('vim.lsp.codelens').refresh()
            end,
        })
    end

    -- Attach any filetype specific options to the client
    filetype_attach[filetype](client)
end

function M.make_default_opts()
    local updated_capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- TODO: check if this is the problem.
    --updated_capabilities.textDocument.codeLens.dynamicRegistration = false
    updated_capabilities.textDocument.completion.completionItem.insertReplaceSupport = false

    return {
        on_init = custom_init,
        on_attach = custom_attach,
        capabilities = updated_capabilities,
        flags = { debounce_text_changes = 50 },
    }
end

return M
