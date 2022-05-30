local M = {}

local ls = require 'luasnip'

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

    ls.add_snippets('c', require 'settings.luasnip.c')
    ls.add_snippets('gitcommit', require 'settings.luasnip.gitcommit')
end

return M
