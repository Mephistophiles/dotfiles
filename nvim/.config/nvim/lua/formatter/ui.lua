local M = {}
local winid, bufnr
local group = vim.api.nvim_create_augroup('FormatterUI', { clear = true })

local function close_menu()
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].modified then
        vim.notify('Save the ignorelist with :w, or use :bwipeout! to discard changes.', vim.log.levels.WARN)
        return
    end
    if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, false)
    end
    winid = nil
end

function M.on_menu_save()
    local entries = vim.tbl_filter(function(line)
        return line:find '%S' ~= nil
    end, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    require('formatter').on_menu_save(entries)
    vim.bo[bufnr].modified = false
end

function M.select_menu_item()
    local filename = vim.api.nvim_get_current_line()
    if filename:find '%S' == nil then
        return
    end
    M.on_menu_save()
    close_menu()
    M.nav_file(filename)
end

function M.nav_file(filename)
    local target = vim.fn.bufadd(filename)
    vim.bo[target].buflisted = true
    vim.api.nvim_set_current_buf(target)
end

function M.toggle_quick_menu(entries)
    if winid and vim.api.nvim_win_is_valid(winid) then
        close_menu()
        return
    end

    local new_buffer = not bufnr or not vim.api.nvim_buf_is_valid(bufnr)
    if new_buffer then
        bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(bufnr, 'formatter-menu')
    end
    local menu_buf = bufnr
    vim.bo[bufnr].buftype = 'acwrite'
    vim.bo[bufnr].bufhidden = 'hide'
    vim.bo[bufnr].filetype = 'formatter'
    if not vim.bo[bufnr].modified then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, entries or require('formatter.ignorelist').get())
        vim.bo[bufnr].modified = false
    end

    local width = math.max(1, math.min(60, vim.o.columns - 4))
    local height = math.max(1, math.min(10, vim.o.lines - 4))
    winid = vim.api.nvim_open_win(bufnr, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = math.max(0, math.floor((vim.o.lines - height - 2) / 2)),
        col = math.max(0, math.floor((vim.o.columns - width - 2) / 2)),
        style = 'minimal',
        border = 'rounded',
        title = ' Formatter ignorelist (:w to save) ',
        title_pos = 'center',
    })
    vim.wo[winid].number = true
    vim.keymap.set('n', 'q', close_menu, { buf = bufnr, desc = 'Close formatter ignorelist' })
    vim.keymap.set('n', '<Esc>', close_menu, { buf = bufnr, desc = 'Close formatter ignorelist' })
    vim.keymap.set('n', '<CR>', M.select_menu_item, { buf = bufnr, desc = 'Save list and open file' })
    vim.api.nvim_clear_autocmds { group = group, buf = bufnr }
    vim.api.nvim_create_autocmd('BufWriteCmd', {
        group = group,
        buf = bufnr,
        callback = M.on_menu_save,
    })
    vim.api.nvim_create_autocmd('BufWipeout', {
        group = group,
        buf = bufnr,
        once = true,
        callback = function()
            if bufnr == menu_buf then
                bufnr, winid = nil, nil
            end
        end,
    })
end

return M
