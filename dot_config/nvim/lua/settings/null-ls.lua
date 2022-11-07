local M = {}

function M.setup()
    local null_ls = require 'null-ls'
    local lspconfig = require 'settings.lspconfig'
    local formatter = require 'settings.formatter'

    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

    formatter.setup()

    local sources = {
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
        null_ls.builtins.formatting.eslint.with {
            disabled_filetypes = { 'json' },
        },
        null_ls.builtins.formatting.prettier.with {
            disabled_filetypes = { 'json' },
        },

        -- code actions
        null_ls.builtins.code_actions.eslint,
        null_ls.builtins.code_actions.shellcheck,

        -- diagnostics
        null_ls.builtins.diagnostics.cppcheck.with {
            condition = function()
                return vim.fn.exepath 'cppcheck' ~= ''
            end,
        },
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.diagnostics.gitlint,
        null_ls.builtins.diagnostics.jsonlint,
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.diagnostics.staticcheck,
        null_ls.builtins.diagnostics.trail_space.with {
            disabled_filetypes = {
                'diff',
                'git',
                'gitcommit',
                'patch',
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
                        formatter.format_document(bufnr)
                    end,
                })

                vim.keymap.set(
                    'n',
                    '<leader>f',
                    [[<CMD>lua require('settings.formatter').format_document()<cr>]],
                    { silent = true, buffer = true, desc = 'Format current document' }
                )
                vim.keymap.set(
                    'v',
                    '<leader>f',
                    [[<CMD>lua require('settings.formatter').format_document()<cr>]],
                    { silent = true, buffer = true, desc = 'Format current selecton in document' }
                )
            end

            lspconfig.key_bindings(client)
        end,
    }
end

return M
