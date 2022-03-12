local M = {}

function M.setup()
    local null_ls = require 'null-ls'
    local cfgpath = vim.fn.stdpath 'config'
    local f = string.format

    require('settings.formatter').setup()

    local sources = {
        null_ls.builtins.formatting.uncrustify.with {
            filetypes = { 'c' },
            args = { '-q', '-lc', '-c', f('%s/uncrustify.cfg', cfgpath) },
        }, -- uncrustify
        null_ls.builtins.formatting.gofmt, -- gofmt
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
        null_ls.builtins.formatting.stylua.with {
            extra_args = { '--config-path', f('%s/stylua.toml', cfgpath) },
        }, -- lua
        null_ls.builtins.formatting.rustfmt, -- fust
    }

    null_ls.setup {
        sources = sources,
        on_attach = function(client)
            if client.resolved_capabilities.document_formatting then
                vim.cmd [[augroup Format]]
                vim.cmd [[autocmd! * <buffer>]]
                vim.cmd [[autocmd BufWritePre <buffer> lua require'settings.formatter'.format_document()]]
                vim.cmd [[augroup END]]

                MAP.nnoremap('<leader>f', function()
                    vim.lsp.buf.formatting()
                end, 'buffer')
            end
        end,
    }
end

return M
