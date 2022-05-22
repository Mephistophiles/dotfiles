local popup = require 'plenary.popup'
local formatter = require 'settings.formatter'

local M = {}

Formatter_win_id = nil
Formatter_bufh = nil

-- We save before we close because we use the state of the buffer as the list
-- of items.
local function close_menu(force_save)
    force_save = force_save or false

    if force_save then
        require('settings.formatter_ui').on_menu_save()
    end

    vim.api.nvim_win_close(Formatter_win_id, true)

    Formatter_win_id = nil
    Formatter_bufh = nil
end

local function create_window()
    local width = 60
    local height = 10
    local borderchars = { [[─]], [[│]], [[─]], [[│]], [[╭]], [[╮]], [[╯]], [[╰]] }
    local bufnr = vim.api.nvim_create_buf(false, false)

    local Formatter_win_id, win = popup.create(bufnr, {
        title = 'Formatter',
        highlight = 'FormatterWindow',
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.api.nvim_win_set_option(win.border.win_id, 'winhl', 'Normal:FormatterBorder')

    return { bufnr = bufnr, win_id = Formatter_win_id }
end

local function is_white_space(str)
    return str:gsub('%s', '') == ''
end

local function get_menu_items()
    local lines = vim.api.nvim_buf_get_lines(Formatter_bufh, 0, -1, true)
    local indices = {}

    for _, line in pairs(lines) do
        if not is_white_space(line) then
            table.insert(indices, line)
        end
    end

    return indices
end

function M.toggle_quick_menu(blacklist)
    if Formatter_win_id ~= nil and vim.api.nvim_win_is_valid(Formatter_win_id) then
        close_menu()
        return
    end

    local win_info = create_window()

    Formatter_win_id = win_info.win_id
    Formatter_bufh = win_info.bufnr

    vim.api.nvim_win_set_option(Formatter_win_id, 'number', true)
    vim.api.nvim_buf_set_name(Formatter_bufh, 'formatter-menu')
    vim.api.nvim_buf_set_lines(Formatter_bufh, 0, #blacklist, false, blacklist)
    vim.api.nvim_buf_set_option(Formatter_bufh, 'filetype', 'formatter')
    vim.api.nvim_buf_set_option(Formatter_bufh, 'buftype', 'acwrite')
    vim.api.nvim_buf_set_option(Formatter_bufh, 'bufhidden', 'delete')
    vim.keymap.set('n', 'q', function()
        M.toggle_quick_menu()
    end, { silent = true, buffer = Formatter_bufh, desc = 'Formatter: quit from menu' })
    vim.keymap.set('n', '<ESC>', function()
        M.toggle_quick_menu()
    end, { silent = true, buffer = Formatter_bufh, desc = 'Formatter: quit from menu' })
    vim.keymap.set('n', '<CR>', function()
        M.select_menu_item()
    end, { buffer = Formatter_bufh, desc = 'Formatter: select menu item' })

    local formatter_ui_group = vim.api.nvim_create_augroup('FormatterUI', { clear = false })

    vim.api.nvim_create_autocmd('BufWriteCmd', {
        group = formatter_ui_group,
        buffer = Formatter_bufh,
        desc = 'Save on exit',
        callback = function()
            M.on_menu_save()
        end,
    })

    vim.api.nvim_create_autocmd('BufModifiedSet', {
        group = formatter_ui_group,
        buffer = Formatter_bufh,
        command = 'set nomodified',
    })

    vim.api.nvim_create_autocmd('BufLeave', {
        group = formatter_ui_group,
        buffer = Formatter_bufh,
        once = true,
        nested = true,
        callback = function()
            M.toggle_quick_menu()
        end,
    })
end

function M.select_menu_item()
    local filename = vim.api.nvim_get_current_line()
    close_menu(true)
    M.nav_file(filename)
end

function M.nav_file(filename)
    local buf_id = vim.fn.bufnr(filename, true)

    vim.api.nvim_set_current_buf(buf_id)
    vim.api.nvim_buf_set_option(buf_id, 'buflisted', true)
end

function M.on_menu_save()
    formatter.on_menu_save(get_menu_items())
end

return M
