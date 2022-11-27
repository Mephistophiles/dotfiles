local M = {}

local lspconfig = require 'lspconfig'
local configs = require 'lspconfig.configs'
local nvim_lsp_signature = require 'lsp_signature'

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

    nvim_lsp_signature.on_attach(client, bufnr)

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

local servers = {
    sumneko_lua = function()
        local runtime_path = vim.split(package.path, ';')
        table.insert(runtime_path, 'lua/?.lua')
        table.insert(runtime_path, 'lua/?/init.lua')

        return {
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT',

                        -- Setup your lua path
                        path = runtime_path,
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { 'vim' },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file('', true),
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = { enable = false },
                },
            },
        }
    end,
    teal_ls = vim.fn.exepath 'tl' ~= '',
    -- rust_analyzer = true,
    clangd = { capabilities = { offsetEncoding = { 'utf-16' } } },
    dhall_lsp_server = true,
    vuels = true,
    tsserver = true,
    gopls = true,
    pylsp = true,
    rnix = true,
}

local setup_server = function(server, config)
    if not config then
        return
    end

    if type(config) == 'function' then
        config = config()

        if not config then
            return
        end
    end

    if type(config) ~= 'table' then
        config = {}
    end

    config = vim.tbl_deep_extend('force', M.make_default_opts(), config)

    lspconfig[server].setup(config)
end

function M.setup()
    vim.lsp.set_log_level 'off'

    for server, config in pairs(servers) do
        setup_server(server, config)
    end
end

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

function M.key_bindings(client)
    local telescope, themes = require('settings.telescope').instance()

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { remap = true, buffer = true, desc = 'LSP: goto declaration' })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { remap = true, buffer = true, desc = 'LSP: goto definition' })
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, { buffer = true, desc = 'LSP: goto type definition' })

    vim.keymap.set('n', 'gi', function()
        telescope.lsp_implementations {
            layout_strategy = 'vertical',
            layout_config = { prompt_position = 'top' },
            sorting_strategy = 'ascending',
            ignore_filename = false,
        }
    end, { buffer = true, desc = 'LSP: goto implementation' })

    vim.keymap.set('n', 'gr', function()
        telescope.lsp_references {
            layout_strategy = 'vertical',
            layout_config = { prompt_position = 'top' },
            sorting_strategy = 'ascending',
            ignore_filename = false,
        }
    end, { buffer = true, desc = 'LSP: goto references' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = true, desc = 'LSP: show code actions' })
    vim.keymap.set('n', '<leader>cs', function()
        telescope.lsp_document_symbols(themes.get_ivy {})
    end, { buffer = true, desc = 'LSP: show document symbols' })
    vim.keymap.set('n', '<leader>cS', function()
        telescope.lsp_workspace_symbols(themes.get_ivy {})
    end, { buffer = true, desc = 'LSP: show workspace symbols' })
    vim.keymap.set('n', '<leader>cd', function()
        telescope.lsp_dynamic_workspace_symbols(themes.get_ivy {})
    end, { buffer = true, desc = 'LSP: show dynamic workspace symbols' })

    vim.keymap.set(
        'n',
        'K',
        vim.lsp.buf.hover,
        { buffer = true, desc = 'LSP: display hover information about the symbol under ther cursor' }
    )
    vim.keymap.set(
        'n',
        '<C-s>',
        vim.lsp.buf.signature_help,
        { buffer = true, desc = 'LSP: display signature information about the symbol under the cursor' }
    )
    vim.keymap.set('n', '<leader>rn', function()
        vim.lsp.buf.rename()
    end, { remap = true, buffer = true, desc = 'LSP: renames all references to the symbol under the cursor' })
    -- vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, nil, "buffer")
    vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { buffer = true, desc = 'LSP: Show diagnostic info' })
    vim.keymap.set('n', '[D', function()
        vim.diagnostic.goto_prev()
    end, { buffer = true, desc = 'LSP: move to the previous diagnostic (whole severities)' })
    vim.keymap.set('n', ']D', function()
        vim.diagnostic.goto_next()
    end, { buffer = true, desc = 'LSP: move to the next diagnostic (whole severities)' })
    vim.keymap.set('n', '[d', function()
        smart_goto_prev()
    end, { buffer = true, desc = 'LSP: move to the previous diagnostic' })
    vim.keymap.set('n', ']d', function()
        smart_goto_next()
    end, { buffer = true, desc = 'LSP: move to the next diagnostic' })
    vim.keymap.set('n', '<leader>q', function()
        vim.diagnostic.setloclist()
    end, { buffer = true, desc = 'LSP: add buffer diagnostics to the location list' })

    if client.supports_method 'textDocument/codeLens' then
        vim.keymap.set(
            'n',
            '<leader>lr',
            vim.lsp.codelens.run,
            { buffer = true, desc = 'LSP: run code lens in the current line' }
        )
    end
end

return M
