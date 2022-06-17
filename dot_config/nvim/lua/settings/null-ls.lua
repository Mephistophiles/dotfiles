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
        null_ls.builtins.formatting.rustfmt,
        null_ls.builtins.formatting.eslint,
        null_ls.builtins.formatting.prettier,

        -- code actions
        null_ls.builtins.code_actions.eslint,
        null_ls.builtins.code_actions.gitrebase,
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.shellcheck,

        -- diagnostics
        null_ls.builtins.diagnostics.cppcheck,
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.diagnostics.gitlint,
        null_ls.builtins.diagnostics.jsonlint,
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.diagnostics.staticcheck,
        null_ls.builtins.diagnostics.trail_space,
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

                vim.keymap.set('n', '<leader>f', function()
                    formatter.format_document()
                end, { silent = true, buffer = true, desc = 'Format current document' })
                -- TODO: range formatting is not supported: https://github.com/neovim/neovim/issues/18371
                vim.keymap.set(
                    'v',
                    '<leader>f',
                    [[:'<,'>lua vim.lsp.buf.range_formatting()<cr>]],
                    { silent = true, buffer = true, desc = 'Format current selecton in document' }
                )

                lspconfig.key_bindings(client)
            end
        end,
    }
end

return M
