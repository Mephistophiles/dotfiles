local cache_path = vim.fn.stdpath 'cache'
local cache_file = cache_path .. '/formatter_blacklist.msgpack'

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

--- @class Blacklist
local BLACKLIST = {}

local function blacklist_file(file)
    local blacklist = BLACKLIST.get()

    if not vim.tbl_contains(blacklist, file) then
        table.insert(blacklist, file)
    end

    BLACKLIST.set(blacklist)
end

local function gc_blacklist(blacklist)
    blacklist = vim.tbl_filter(function(file)
        local st = vim.loop.fs_stat(file)
        return st ~= nil -- and (st.type == 'file' or st.type == 'directory')
    end, blacklist)

    BLACKLIST.set(blacklist)

    return blacklist
end

local function unblacklist_file(file)
    local blacklist = BLACKLIST.get()

    blacklist = vim.tbl_filter(function(f)
        return f ~= file
    end, blacklist)

    BLACKLIST.set(blacklist)
end

local function is_blacklisted_file(file)
    local blacklist = BLACKLIST.get()

    for _, f in ipairs(blacklist) do
        if vim.startswith(file, f) then
            return true
        end
    end

    return false
end

function BLACKLIST.empty()
    return {}
end

--- Gets the current blacklist
--- @return Blacklist
function BLACKLIST.get()
    local opened, cache = pcall(vim.fn.readfile, cache_file, 'b')
    if not opened then
        return BLACKLIST.empty()
    end
    local parsed, ret = pcall(vim.fn.msgpackparse, cache)

    if parsed then
        return ret
    else
        vim.loop.fs_unlink(cache_file)
        return BLACKLIST.empty()
    end
end

--- Override current blacklist
--- @param blacklist Blacklist
function BLACKLIST.set(blacklist)
    vim.fn.writefile(vim.fn.msgpackdump(blacklist), cache_file, 'b')
end

function M.on_menu_save(blacklist)
    BLACKLIST.set(blacklist)
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

    vim.keymap.set('n', '<leader>mb', function()
        blacklist_file(vim.api.nvim_buf_get_name(0))
        vim.b.disable_formatter = true
        vim.notify 'Permanently disable format on save'
    end, { desc = 'Formatter: permanently disable format for current file' })
    vim.keymap.set('n', '<leader>mu', function()
        unblacklist_file(vim.api.nvim_buf_get_name(0))
        vim.b.disable_formatter = false
        vim.notify 'Remove current file from the blacklist'
    end, { desc = 'Formatter: remove current file from the blacklist' })
    vim.keymap.set('n', '<leader>mc', function()
        local before = BLACKLIST.get()
        local after = gc_blacklist(before)
        vim.notify(string.format('GC blacklist: %d -> %d entries', #before, #after))
    end, { desc = 'Formatter: run garbage collector in blacklist' })
    vim.keymap.set('n', '<leader>ml', function()
        require('settings.formatter_ui').toggle_quick_menu(BLACKLIST.get())
    end, { desc = 'Formatter: open blacklist menu' })
end

function M.format_document(force, bufnr)
    if not force and vim.b.disable_formatter then
        return
    end

    if not force and is_blacklisted_file(vim.api.nvim_buf_get_name(0)) then
        return
    end

    lsp_formatting(bufnr)
end

return M
