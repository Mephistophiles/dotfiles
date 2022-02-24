local M = {}

local lspconfig = require 'lspconfig'
local configs = require 'lspconfig.configs'
local nvim_lsp_signature = require 'lsp_signature'

local custom_init = function(client)
    client.config.flags = client.config.flags or {}
    client.config.flags.allow_incremental_sync = true
end

local filetype_attach = setmetatable({go = function() end, rust = function() end},
                                     {__index = function() return function() end end})

local custom_attach = function(client, bufnr)
    local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

    nvim_lsp_signature.on_attach(client, bufnr)

    M.key_bindings(client)

    vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'

    if client.resolved_capabilities.document_formatting then
        vim.cmd [[augroup Format]]
        vim.cmd [[autocmd! * <buffer>]]
        vim.cmd [[autocmd BufWritePost <buffer> lua require'settings.formatter'.format_document()]]
        vim.cmd [[augroup END]]
    end

    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
        vim.cmd [[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
    end

    if client.resolved_capabilities.code_lens then
        vim.cmd [[
      augroup lsp_document_codelens
        au! * <buffer>
        autocmd BufEnter ++once         <buffer> lua require"vim.lsp.codelens".refresh()
        autocmd BufWritePost,CursorHold <buffer> lua require"vim.lsp.codelens".refresh()
      augroup END
    ]]
    end

    -- Attach any filetype specific options to the client
    filetype_attach[filetype](client)
end

function M.make_default_opts()
    local updated_capabilities = vim.lsp.protocol.make_client_capabilities()
    updated_capabilities.textDocument.codeLens = {dynamicRegistration = false}
    updated_capabilities = require('cmp_nvim_lsp').update_capabilities(updated_capabilities)

    -- TODO: check if this is the problem.
    updated_capabilities.textDocument.completion.completionItem.insertReplaceSupport = false

    return {
        on_init = custom_init,
        on_attach = custom_attach,
        capabilities = updated_capabilities,
        flags = {debounce_text_changes = 50},
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
                        globals = {'vim'},
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file('', true),
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {enable = false},
                },
            },
        }
    end,
    teal = function()
        if vim.fn.exepath('tl') == '' then return end

        configs.teal = {
            default_config = {
                cmd = {
                    'teal-language-server',
                    -- "logging=on", use this to enable logging in /tmp/teal-language-server.log
                },
                filetypes = {
                    'teal',
                    -- "lua", -- Also works for lua, but you may get type errors that cannot be resolved within lua itself
                },
                root_dir = lspconfig.util.root_pattern('tlconfig.lua', '.git'),
                settings = {},
            },
        }

        return {}
    end,
    efm = function()
        require('settings.formatter').setup()

        return {
            init_options = {documentFormatting = true},
            filetypes = {'lua'},
            root_dir = require('lspconfig').util.root_pattern {'.git/', '.'},
            settings = {
                -- root_dir = lspconfig.util.root_pattern{'.git/', "."},
                lintDebounce = 100,
                languages = {
                    -- ["="] = { misspell },
                    c = {
                        require('settings.efm.c_uncrustify'),
                        require('settings.efm.c_clang_format'),
                    },
                    go = {require('settings.efm.go')},
                    json = {require('settings.efm.json')},
                    lua = {require('settings.efm.lua')},
                    rust = {require('settings.efm.rust')},
                },
            },
        }
    end,
    -- rust_analyzer = true,
    tsserver = {cmd = require'lspcontainers'.command('tsserver')},
    clangd = true,
    gopls = true,
    pylsp = true,
    rnix = true,
}

local setup_server = function(server, config)
    if not config then return end

    if type(config) == 'function' then
        config = config()

        if not config then return end
    end

    if type(config) ~= 'table' then config = {} end

    config = vim.tbl_deep_extend('force', M.make_default_opts(), config)

    lspconfig[server].setup(config)
end

function M.setup() for server, config in pairs(servers) do setup_server(server, config) end end

function M.key_bindings(client)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    MAP.nnoremap('gD', vim.lsp.buf.declaration, 'buffer')
    MAP.nnoremap('gd', vim.lsp.buf.definition, 'buffer')
    MAP.nnoremap('<leader>D', vim.lsp.buf.type_definition, 'buffer')

    MAP.nnoremap('gi', function()
        require('telescope.builtin').lsp_implementations {
            layout_strategy = 'vertical',
            layout_config = {prompt_position = 'top'},
            sorting_strategy = 'ascending',
            ignore_filename = false,
        }
    end, 'buffer')

    MAP.nnoremap('gr', function()
        require('telescope.builtin').lsp_references {
            layout_strategy = 'vertical',
            layout_config = {prompt_position = 'top'},
            sorting_strategy = 'ascending',
            ignore_filename = false,
        }
    end, 'buffer')
    MAP.nnoremap('<leader>ca', function()
        local themes = require 'telescope.themes'
        local opts = themes.get_dropdown {
            winblend = 10,
            border = true,
            previewer = false,
            shorten_path = false,
        }

        require('telescope.builtin').lsp_code_actions(opts)
    end, 'buffer')

    MAP.nnoremap('K', vim.lsp.buf.hover, 'buffer')
    MAP.nnoremap('<C-s>', vim.lsp.buf.signature_help, 'buffer')
    MAP.nnoremap('<leader>rn', function() vim.lsp.buf.rename() end, 'buffer')
    -- MAP.nnoremap('<leader>ca', vim.lsp.buf.code_action, nil, "buffer")
    if client.resolved_capabilities.document_formatting then
        MAP.nnoremap('<leader>f', function() vim.lsp.buf.formatting() end, 'buffer')
    end

    MAP.nnoremap('<leader>d', vim.diagnostic.open_float, 'buffer')
    MAP.nnoremap('[d', function() vim.diagnostic.goto_next() end, 'buffer')
    MAP.nnoremap(']d', function() vim.diagnostic.goto_prev() end, 'buffer')
    MAP.nnoremap('<leader>q', function() vim.diagnostic.setloclist() end, 'buffer')

    if client.resolved_capabilities.code_lens then
        MAP.nnoremap('<leader>lr', vim.lsp.codelens.run, 'buffer')
    end
end

return M
