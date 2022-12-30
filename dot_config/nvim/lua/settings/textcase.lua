local M = {}

function M.setup() end

function M.config()
    require('textcase').setup {}
    require('telescope').load_extension 'textcase'
end

return M
