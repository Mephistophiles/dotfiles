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

local function key_bindings(client)
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

    vim.keymap.set(
        'n',
        '<leader>lf',
        vim.lsp.buf.format,
        { buffer = true, desc = 'LSP: format document by lsp engine' }
    )

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

    key_bindings(client)

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

local function make_default_opts()
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

local exe_resolve = function(name)
    if vim.fn.exepath(name) then
        return name
    end
end

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

    config = vim.tbl_deep_extend('force', make_default_opts(), config)

    require('lspconfig')[server].setup(config)
end

return {
    { -- Quickstart configs for Nvim LSP
        'neovim/nvim-lspconfig',
        event = { 'BufRead', 'BufWinEnter', 'BufNewFile' },
        name = 'lspconfig',
        config = function()
            vim.lsp.set_log_level 'off'

            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = {
                                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                                version = 'LuaJIT',
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
                            telemetry = {
                                enable = false,
                            },
                        },
                    },
                },
                -- rust_analyzer = true, -- via rust-tools
                clangd = { capabilities = { offsetEncoding = { 'utf-16' } } },
                gopls = true,
                jsonls = {
                    cmd = { exe_resolve 'vscode-json-languageserver' or 'vscode-json-language-server', '--stdio' },
                },
                pylsp = true,
                pyright = true,
                yamlls = require('yaml-companion').setup {
                    schemas = {
                        {
                            name = 'Gitlab CI',
                            uri = 'https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json',
                        },
                    },
                },
            }

            for server, config in pairs(servers) do
                setup_server(server, config)
            end
        end,
    },
    {
        'glepnir/lspsaga.nvim',
        event = 'LspAttach',
        config = function()
            require('lspsaga').setup {}
        end,
        dependencies = {
            { 'nvim-tree/nvim-web-devicons' },
            --Please make sure you install markdown and markdown_inline parser
            { 'nvim-treesitter/nvim-treesitter' },
        },
    },
    { -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
        'jose-elias-alvarez/null-ls.nvim',
        event = 'VeryLazy',
        config = function()
            local null_ls = require 'null-ls'
            local methods = require 'null-ls.methods'
            local helpers = require 'null-ls.helpers'

            local formatter = require 'plugins.utils.formatter'

            local clang_tidy = helpers.make_builtin {
                method = methods.internal.DIAGNOSTICS_ON_SAVE,
                filetypes = { 'c', 'c++' },
                command = 'clang-tidy',
                generator_opts = {
                    args = { '--quiet', '$FILENAME' },
                    format = 'line',
                    ignore_stderr = true,
                    on_output = helpers.diagnostics.from_pattern(
                        ':(%d+):(%d+): (%w+): (.*)$',
                        { 'row', 'col', 'severity', 'message' },
                        {
                            severities = {
                                ['fatal error'] = helpers.diagnostics.severities.error,
                                ['error'] = helpers.diagnostics.severities.error,
                                ['note'] = helpers.diagnostics.severities.information,
                                ['warning'] = helpers.diagnostics.severities.warning,
                            },
                        }
                    ),
                },
                factory = helpers.generator_factory,
            }

            local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

            formatter.setup()

            local sources = {
                null_ls.builtins.formatting.autopep8,
                null_ls.builtins.formatting.clang_format.with {
                    condition = function(utils)
                        return utils.root_has_file '.clang-format'
                    end,
                },
                null_ls.builtins.formatting.gofmt,
                null_ls.builtins.formatting.json_tool.with {
                    command = 'jq',
                    args = { '--indent', '4' },
                    extra_args = function()
                        if vim.b.formatter_sort_keys then
                            return { '--sort-keys' }
                        end
                        return {}
                    end,
                }, -- json
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.rustfmt.with {
                    extra_args = function(params)
                        local Path = require 'plenary.path'
                        local cargo_toml = Path:new(params.root .. '/' .. 'Cargo.toml')

                        if cargo_toml:exists() and cargo_toml:is_file() then
                            for _, line in ipairs(cargo_toml:readlines()) do
                                local edition = line:match [[^edition%s*=%s*%"(%d+)%"]]
                                if edition then
                                    return { '--edition=' .. edition }
                                end
                            end
                        end
                        -- default edition when we don't find `Cargo.toml` or the `edition` in it.
                        return { '--edition=2021' }
                    end,
                },

                -- diagnostics
                null_ls.builtins.diagnostics.cppcheck.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                    condition = function()
                        return vim.fn.exepath 'cppcheck' ~= ''
                    end,
                },
                clang_tidy.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                    condition = function()
                        return vim.fn.exepath 'clang-tidy' ~= ''
                    end,
                },
                null_ls.builtins.diagnostics.gitlint.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                },
                null_ls.builtins.diagnostics.jsonlint.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                },
                null_ls.builtins.diagnostics.mypy.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                },
                null_ls.builtins.diagnostics.pylint.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                },
                null_ls.builtins.diagnostics.shellcheck.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                },
                null_ls.builtins.diagnostics.staticcheck.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                },
                null_ls.builtins.diagnostics.trail_space.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                    disabled_filetypes = {
                        'diff',
                        'git',
                        'gitcommit',
                        'patch',
                        'strace',
                    },
                },
            }

            null_ls.setup {
                debug = false,
                sources = sources,
                on_attach = function(client, bufnr)
                    if client.supports_method 'textDocument/formatting' then
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            group = augroup,
                            desc = 'Format document on save',
                            buffer = 0,
                            callback = function()
                                formatter.format_document(false, bufnr)
                            end,
                        })

                        vim.keymap.set('n', '<leader>f', function()
                            formatter.format_document(true)
                        end, { silent = true, buffer = true, desc = 'Format current document' })
                        vim.keymap.set('v', '<leader>f', function()
                            formatter.format_document(true)
                            vim.api.nvim_input '<Esc>'
                        end, {
                            silent = true,
                            buffer = true,
                            desc = 'Format current selecton in document',
                        })
                    end

                    key_bindings(client)
                end,
            }
        end,
        dependencies = { 'nvim-lua/plenary.nvim' },
    },
    {
        'someone-stole-my-name/yaml-companion.nvim',
        module = 'yaml-companion',
        dependencies = {
            { 'neovim/nvim-lspconfig', name = 'lspconfig' },
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-telescope/telescope.nvim' },
        },
        config = function()
            require('telescope').load_extension 'yaml_schema'
        end,
    },
    { -- Tools for better development in rust using neovim's builtin lsp
        'simrat39/rust-tools.nvim',
        ft = 'rust',
        event = { 'BufRead', 'BufWinEnter', 'BufNewFile' },
        dependencies = { 'neovim/nvim-lspconfig', name = 'lspconfig' },
        config = function()
            local server = vim.tbl_deep_extend('force', make_default_opts(), {
                flags = { allow_incremental_sync = true },
                settings = {
                    ['rust-analyzer'] = {
                        assist = { importGranularity = 'module', importPrefix = 'by_self' },
                        cargo = { loadOutDirsFromCheck = true, allFeatures = true },
                        procMacro = { enable = true },
                        checkOnSave = { command = 'clippy' },
                        experimental = { procAttrMacros = true },
                        lens = { methodReferences = true, references = true },
                    },
                },
            })

            local dap = {
                adapter = {
                    type = 'executable',
                    name = 'lldb',
                },
            }

            local opts = { server = server, dap = dap }

            require('rust-tools').setup(opts)
        end,
    },
    { -- A neovim plugin that helps managing crates.io dependencies
        'saecki/crates.nvim',
        ft = 'rust',
        event = { 'BufRead Cargo.toml' },
        dependencies = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            require('crates').setup()
        end,
    },
}
