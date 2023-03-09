local utils = require 'plugins.express_line.utils'

local M = {}

function M.format_func(separator)
    local ts_status = require 'nvim-treesitter.statusline'
    if not separator then
        separator = ''
    end
    return utils.throttle_fn(function()
        if vim.bo.buftype ~= '' or vim.wo.previewwindow then
            return
        end

        local context = ts_status.statusline()

        if #context > 0 then
            return context .. separator
        end
        return ''
    end)
end

return M
