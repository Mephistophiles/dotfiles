local cache_path = vim.fn.stdpath 'cache'
local cache_file = cache_path .. '/formatter_ignorelist.msgpack'

local M = {}

local lsp_formatting = function(bufnr)
    vim.lsp.buf.format {
        filter = function(client)
            return client.name == 'null-ls'
        end,
        timeout_ms = 2000,
        bufnr = bufnr,
    }
end

--- @class Ignorelist
local IGNORELIST = {}

local function ignore_file(file)
    local ignorelist = IGNORELIST.get()

    if not vim.tbl_contains(ignorelist, file) then
        table.insert(ignorelist, file)
    end

    IGNORELIST.set(ignorelist)
end

local function gc_ignorelist(ignorelist)
    ignorelist = vim.tbl_filter(function(file)
        local st = vim.loop.fs_stat(file)
        return st ~= nil -- and (st.type == 'file' or st.type == 'directory')
    end, ignorelist)

    IGNORELIST.set(ignorelist)

    return ignorelist
end

local function unignore_file(file)
    local ignorelist = IGNORELIST.get()

    ignorelist = vim.tbl_filter(function(f)
        return f ~= file
    end, ignorelist)

    IGNORELIST.set(ignorelist)
end

local function is_ignored_file(file)
    local denylist = IGNORELIST.get()

    for _, pattern in ipairs(denylist) do
        local pattern_regex = vim.regex(vim.fn.glob2regpat(pattern))
        if pattern_regex:match_str(file) then
            return true
        end
    end

    return false
end

function IGNORELIST.empty()
    return {}
end

--- Gets the current ignorelist
--- @return Ignorelist
function IGNORELIST.get()
    local opened, cache = pcall(vim.fn.readfile, cache_file, 'b')
    if not opened then
        return IGNORELIST.empty()
    end
    local parsed, ret = pcall(vim.fn.msgpackparse, cache)

    if parsed then
        return ret
    else
        vim.loop.fs_unlink(cache_file)
        return IGNORELIST.empty()
    end
end

--- Override current ignorelist
--- @param ignorelist Ignorelist
function IGNORELIST.set(ignorelist)
    vim.fn.writefile(vim.fn.msgpackdump(ignorelist), cache_file, 'b')
end

function M.on_menu_save(ignorelist)
    IGNORELIST.set(ignorelist)
end

function M.setup()
    vim.keymap.set('n', '<leader>m', function()
        if vim.b.disable_formatter then
            vim.b.disable_formatter = false
            vim.notify 'Enable format on save'
        else
            vim.b.disable_formatter = true
            vim.notify 'Disable format on save'
        end
    end, { desc = 'Formatter: toggle formatter in current document' })

    vim.keymap.set('n', '<leader>mi', function()
        ignore_file(vim.api.nvim_buf_get_name(0))
        vim.b.disable_formatter = true
        vim.notify 'Permanently disable format on save'
    end, { desc = 'Formatter: permanently disable format for current file' })
    vim.keymap.set('n', '<leader>mu', function()
        unignore_file(vim.api.nvim_buf_get_name(0))
        vim.b.disable_formatter = false
        vim.notify 'Remove current file from the ignorelist'
    end, { desc = 'Formatter: remove current file from the ignorelist' })
    vim.keymap.set('n', '<leader>mc', function()
        local before = IGNORELIST.get()
        local after = gc_ignorelist(before)
        vim.notify(string.format('GC ignorelist: %d -> %d entries', #before, #after))
    end, { desc = 'Formatter: run garbage collector in ignorelist' })
    vim.keymap.set('n', '<leader>ml', function()
        require('plugins.formatter.formatter_ui').toggle_quick_menu(IGNORELIST.get())
    end, { desc = 'Formatter: open ignorelistmenu' })
end

function M.format_document(force, bufnr)
    if not force and vim.b.disable_formatter then
        return
    end

    if not force and is_ignored_file(vim.api.nvim_buf_get_name(0)) then
        return
    end

    lsp_formatting(bufnr)
end

return M
