local M = {}

function M.config()
    require('filetype').setup {
        overrides = {
            extensions = {
                tl = 'teal',
            },
            function_complex = {
                ['Config.in'] = function()
                    vim.bo.filetype = 'kconfig'
                end,
            },
        },
        function_extensions = {
            ['c'] = function()
                vim.bo.expandtab = true
            end,
        },
    }
end

return M
