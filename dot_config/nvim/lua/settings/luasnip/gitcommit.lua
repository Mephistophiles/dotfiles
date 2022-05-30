local ls = require 'luasnip'
local i = ls.insert_node
local s = ls.s
local f = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt

local function get_signoff()
    local username = io.popen('git config user.name', 'r'):read '*l'
    local email = io.popen('git config user.email', 'r'):read '*l'

    return string.format('%s <%s>', username, email)
end

return {
    s('sob', fmt([[Signed-off-by: {}]], { f(get_signoff, {}) })),
    s('cdb', fmt([[Co-developed-by: {}]], { i(0) })),
}
