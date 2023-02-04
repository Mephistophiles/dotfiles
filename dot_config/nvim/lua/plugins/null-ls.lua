return { -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
    'jose-elias-alvarez/null-ls.nvim',
    event = 'VeryLazy',
    config = function()
        local null_ls = require 'null-ls'
        local methods = require 'null-ls.methods'
        local helpers = require 'null-ls.helpers'

        local lspconfig = require 'plugins.lsp.utils'
        local formatter = require 'plugins.formatter.formatter'

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

                lspconfig.key_bindings(client)
            end,
        }
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
}
