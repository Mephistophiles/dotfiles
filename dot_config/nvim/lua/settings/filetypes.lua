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
    }
end

return M
