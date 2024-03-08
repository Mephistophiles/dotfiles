local clangd = {
    'clangd',
    function()
        return {
            cmd = {
                -- see clangd --help-hidden
                'clangd',
                '--background-index',
                -- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
                -- to add more checks, create .clang-tidy file in the root directory
                -- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
                '--clang-tidy',
                '--completion-style=bundled',
                '--cross-file-rename',
                '--header-insertion=iwyu',
            },
            capabilities = { offsetEncoding = { 'utf-16' } },
        }
    end,
}

local supported_languages = {
    c = clangd,
    cpp = clangd,
    go = {
        'gopls',
    },
    json = {
        'jsonls',
        function()
            local exe_resolve = function(name)
                if vim.fn.exepath(name) then
                    return name
                end
            end
            return {
                cmd = { exe_resolve 'vscode-json-languageserver' or 'vscode-json-language-server', '--stdio' },
            }
        end,
    },
    nix = {
        'rnix',
        'nixd',
    },
    lua = {
        'lua_ls',
        function()
            return {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = 'Replace',
                        },
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
                            -- Disable busted asks
                            checkThirdParty = false,
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }
        end,
    },
    python = {
        'pylsp',
        'pyright',
        'ruff_lsp',
    },
}

local event_pattern = vim.tbl_map(function(ft)
    return 'FileType ' .. ft
end, vim.tbl_keys(supported_languages))

return {
    {
        -- Quickstart configs for Nvim LSP
        'neovim/nvim-lspconfig',
        event = event_pattern,
        name = 'lspconfig',
        config = function()
            vim.lsp.set_log_level 'off'
            local lsp_config = require 'lspconfig'
            local lsp_utils = require 'plugins.utils.lsp'

            for lang, configs in pairs(supported_languages) do
                local lsp_servers = {}
                local current_server = nil

                for _, item in ipairs(configs) do
                    if type(item) == 'string' then
                        current_server = item
                        lsp_servers[current_server] = {}
                    elseif type(item) == 'function' then
                        lsp_servers[assert(current_server)] = item()
                    elseif type(item) == 'table' then
                        lsp_servers[assert(current_server)] = item
                    else
                        error('Invalid type: ' .. string(item) .. ' for lang ' .. lang)
                    end
                end

                for server, config in pairs(lsp_servers) do
                    lsp_config[server].setup(lsp_utils.make_default_opts(config))
                end

                vim.diagnostic.config {
                    severity_sort = true,
                    signs = true,
                    update_in_insert = true,
                    underline = true,
                }
            end
        end,
    },
    {
        'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
        keys = {
            {
                '<leader>ll',
                function()
                    require('lsp_lines').toggle()
                end,
                desc = 'LspLines: toggle',
            },
        },
        config = function()
            require('lsp_lines').setup()
        end,
    },
    {
        'doums/suit.nvim',
        opts = {},
        event = 'VeryLazy',
    },
    {
        'nvimtools/none-ls.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            local null_ls = require 'null-ls'

            local methods = require 'null-ls.methods'
            local helpers = require 'null-ls.helpers'

            local clang_analyzer = helpers.make_builtin {
                method = methods.internal.DIAGNOSTICS_ON_SAVE,
                filetypes = { 'c', 'c++' },
                command = 'clang-analyzer',
                generator_opts = {
                    args = { '$FILENAME' },
                    format = 'line',
                    from_stderr = true,
                    -- <file>:167:5: warning: Value stored to 'size' is never read [deadcode.DeadStores]
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

            local jq = helpers.make_builtin {
                name = 'jq',
                method = methods.internal.FORMATTING,
                filetypes = { 'json' },
                generator_opts = {
                    command = 'jq',
                    args = { '--indent', '4' },
                    extra_args = function()
                        if vim.b.formatter_sort_keys then
                            return { '--sort-keys' }
                        end
                        return {}
                    end,
                    to_stdin = true,
                },
                factory = helpers.formatter_factory,
            }

            local sources = {
                -- Formatters
                null_ls.builtins.formatting.clang_format.with {
                    condition = function(utils)
                        return utils.root_has_file '.clang-format'
                    end,
                },
                null_ls.builtins.formatting.gofmt,
                jq,
                null_ls.builtins.formatting.stylua,
                -- Diagnostics
                clang_analyzer.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                },
                null_ls.builtins.diagnostics.gitlint.with {
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                },
                helpers.make_builtin {
                    name = 'shellcheck',
                    meta = {
                        url = 'https://www.shellcheck.net/',
                        description = 'A shell script static analysis tool.',
                    },
                    method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                    filetypes = { 'sh' },
                    generator_opts = {
                        command = 'shellcheck',
                        args = { '--format', 'json1', '--source-path=$DIRNAME', '--external-sources', '-' },
                        to_stdin = true,
                        format = 'json',
                        check_exit_code = function(code)
                            return code <= 1
                        end,
                        on_output = function(params)
                            local parser = helpers.diagnostics.from_json {
                                attributes = { code = 'code' },
                                severities = {
                                    info = helpers.diagnostics.severities['information'],
                                    style = helpers.diagnostics.severities['hint'],
                                },
                            }

                            return parser { output = params.output.comments }
                        end,
                    },
                    factory = helpers.generator_factory,
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
                    require('plugins.utils.formatter').attach_formatter(client, bufnr)
                end,
            }
        end,
    },
    {
        -- Tools for better development in rust using neovim's builtin lsp
        'simrat39/rust-tools.nvim',
        event = { 'BufRead *.rs', 'BufWinEnter *.rs', 'BufNewFile *.rs' },
        dependencies = { 'neovim/nvim-lspconfig', name = 'lspconfig' },
        config = function()
            local server = vim.tbl_deep_extend('force', require('plugins.utils.lsp').make_default_opts(), {
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
    {
        -- A neovim plugin that helps managing crates.io dependencies
        'saecki/crates.nvim',
        event = { 'BufRead Cargo.toml' },
        dependencies = { { 'nvim-lua/plenary.nvim' } },
        opts = {},
    },
}
