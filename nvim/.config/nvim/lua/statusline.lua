require('vim._core.ui2').enable()

local function get_git_status()
    local gs = vim.b.gitsigns_status_dict
    if not gs or (not gs.head or gs.head == '') then
        return ''
    end

    local parts = {}

    table.insert(parts, ' ' .. gs.head)

    -- Added (красим, если > 0)
    if (gs.added or 0) > 0 then
        table.insert(parts, string.format('%%#GitSignsAddNr#+%d', gs.added))
    end

    -- Changed (красим, если > 0)
    if (gs.changed or 0) > 0 then
        table.insert(parts, string.format('%%#GitSignsChangeNr#~%d', gs.changed))
    end

    -- Removed (красим, если > 0)
    if (gs.removed or 0) > 0 then
        table.insert(parts, string.format('%%#GitSignsDeleteNr#-%d', gs.removed))
    end

    -- Сбрасываем цвет обратно в стандартный для остальной части статуслайна
    table.insert(parts, '%#StatusLine# ')

    return table.concat(parts, ' ')
end

local util = require 'vim._core.util'

function _G.my_statusline()
    local status = {
        '%<%f', -- File name with truncation
        '%h%w%m%r', -- Flags
        util.term_exitcode(),
        get_git_status(),
        vim.ui.progress_status() or '', -- [New] LSP Progress
        vim.bo.busy > 0 and '◐ ' or '',
        vim.diagnostic.status() or '', -- [New] Diagnostics
        '%=', -- Right align separator
        ' ',
        ' %-14.(%l,%c%) %P', -- Line, Col, Percentage
    }
    return table.concat(status, ' ')
end

vim.opt.statusline = '%!v:lua.my_statusline()'
vim.opt.laststatus = 3
