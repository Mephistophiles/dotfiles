local M = {}

local api = vim.api
local actions = require('spectre.actions')

function M.do_and_open(cmd)
    local entry = actions.get_current_entry()
    if entry == nil then return end

    vim.api.nvim_command [[execute "normal! m` "]]
    vim.cmd(cmd .. ' ' .. entry.filename)
    api.nvim_win_set_cursor(0, {entry.lnum, entry.col})
end

function M.vsplit() M.do_and_open('vsplit') end
function M.split() M.do_and_open('split') end
function M.tabsplit() M.do_and_open('tab split') end

return M
