local utils = require 'plugins.express_line.utils'
local M = {}

function M.format_func(separator)
    return utils.throttle_fn(function()
        local output = {}
        local cache = {}

        for _, c in pairs(vim.lsp.buf_get_clients()) do
            if c.name ~= 'null-ls' then
                for _, ctx in pairs(c.messages.progress) do
                    if not ctx.done then
                        cache[c.id] = string.format('%s: %s %s %d%%%%', c.name, ctx.title, ctx.message, ctx.percentage)
                    else
                        cache[c.id] = c.name
                    end
                end
            end
        end

        for _, item in ipairs(cache) do
            table.insert(output, item)
        end

        if #output > 0 then
            return '[LSP] ' .. table.concat(output, ' | ') .. separator
        end

        return ''
    end)
end

return M
