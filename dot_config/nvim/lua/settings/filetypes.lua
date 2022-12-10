local M = {}

function M.config()
    require('filetype').setup {
        overrides = {
            extensions = {
                tl = 'teal',
            },
            literal = {
                ['Config.in'] = 'kconfig',
            },
        },
    }
end

return M
