local M = {}

function M.setup()
    local null_ls = require 'null-ls'
    local lspconfig = require 'settings.lspconfig'
    local cfgpath = vim.fn.stdpath 'config'
    local f = string.format

    require('settings.formatter').setup()

    local sources = {
        null_ls.builtins.formatting.uncrustify.with {
            filetypes = { 'c' },
            args = { '-q', '-lc', '-c', f('%s/uncrustify.cfg', cfgpath) },
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

        -- diagnostics
        null_ls.builtins.diagnostics.jsonlint,
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.diagnostics.gitlint,
    }

    null_ls.setup {
        debug = false,
        sources = sources,
        on_attach = function(client)
            if client.resolved_capabilities.document_formatting then
                vim.cmd [[augroup Format]]
                vim.cmd [[autocmd! * <buffer>]]
                vim.cmd [[autocmd BufWritePre <buffer> lua require'settings.formatter'.format_document()]]
                vim.cmd [[augroup END]]

                vim.keymap.set(
                    'n',
                    '<leader>f',
                    [[:lua vim.lsp.buf.formatting()<cr>]],
                    { silent = true, buffer = true }
                )
                vim.keymap.set(
                    'v',
                    '<leader>f',
                    [[:'<,'>lua vim.lsp.buf.range_formatting()<cr>]],
                    { silent = true, buffer = true }
                )

                lspconfig.key_bindings(client)
            end
        end,
    }
end

return M
