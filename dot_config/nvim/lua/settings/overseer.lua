local M = {}

function M.config()
    require('overseer').setup {
        strategy = 'terminal',
    }
end

return M
