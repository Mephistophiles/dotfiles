require('luasnip.session.snippet_collection').clear_snippets 'gitcommit'

local ls = require 'luasnip'

local s = ls.snippet
local i = ls.insert_node

local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets('gitcommit', {
    s('signoff', fmt('Signed-off-by: {}', i(1))),
})
