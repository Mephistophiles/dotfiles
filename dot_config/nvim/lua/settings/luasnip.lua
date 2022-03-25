local M = {}

local ls = require 'luasnip'
local snippet = ls.s
local t = ls.text_node
local i = ls.insert_node

local shortcut = function(val)
    if type(val) == 'string' then
        return { t { val }, i(0) }
    end

    if type(val) == 'table' then
        for k, v in ipairs(val) do
            if type(v) == 'string' then
                val[k] = t { v }
            end
        end
    end

    return val
end

local make = function(tbl)
    local result = {}

    for k, v in pairs(tbl) do
        table.insert(result, snippet({ trig = k, desc = v.desc }, shortcut(v)))
    end

    return result
end

function M.setup()
    ls.config.set_config {
        -- This tells LuaSnip to remember to keep around the last snippet.
        -- You can jump back into it even if you move outside of the selection
        history = true,

        -- This one is cool cause if you have dynamic snippets, it updates as you type!
        updateevents = 'TextChanged,TextChangedI',

        -- Autosnippets:
        enable_autosnippets = true,
    }

    ls.snippets = {
        c = make(require 'settings.luasnip.c'),
    }
end

return M
