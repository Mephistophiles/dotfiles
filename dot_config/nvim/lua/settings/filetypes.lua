local M = {}

function M.config()
    require('filetype').setup {
        overrides = {
            extensions = {
                tl = 'teal',
            },
            function_extensions = {
                ['dm'] = function()
                    vim.bo.filetype = 'json'
                    vim.bo.shiftwidth = 4
                    vim.bo.textwidth = 4
                    vim.bo.expandtab = true
                end,
            },
            function_complex = {
                ['Config.in'] = function()
                    vim.bo.filetype = 'kconfig'
                end,
                ['.*_config.default'] = function()
                    vim.bo.filetype = 'json'
                    vim.bo.shiftwidth = 4
                    vim.bo.textwidth = 4
                    vim.bo.expandtab = true
                    vim.b.formatter_sort_keys = true
                end,
            },
        },
    }
end

return M
