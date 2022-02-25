local cache_path = vim.fn.stdpath 'cache'
local cache_file = cache_path .. '/formatter_blacklist.msgpack'

local M = {}

--- @class Blacklist
local BLACKLIST = {}

local function blacklist_file(file)
    local blacklist = BLACKLIST.get()

    if not vim.tbl_contains(blacklist, file) then table.insert(blacklist, file) end

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

    blacklist = vim.tbl_filter(function(f) return f ~= file end, blacklist)

    BLACKLIST.set(blacklist)
end

local function is_blacklisted_file(file)
    local blacklist = BLACKLIST.get()

    for _, f in ipairs(blacklist) do if vim.startswith(file, f) then return true end end

    return false
end

function BLACKLIST.empty() return {} end

--- Gets the current blacklist
--- @return Blacklist
function BLACKLIST.get()
    local opened, cache = pcall(vim.fn.readfile, cache_file, 'b')
    if not opened then return BLACKLIST.empty() end
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
function BLACKLIST.set(blacklist) vim.fn.writefile(vim.fn.msgpackdump(blacklist), cache_file, 'b') end

function M.on_menu_save(blacklist) BLACKLIST.set(blacklist) end

function M.setup()
    vim.b.enable_formatter = true

    MAP.nnoremap('<leader>m', function()
        if not vim.b.enable_formatter then
            vim.b.enable_formatter = true
            vim.notify('Enable format on save')
        else
            vim.b.enable_formatter = false
            vim.notify('Disable format on save')
        end
    end)

    MAP.nnoremap('<leader>mb', function()
        blacklist_file(vim.api.nvim_buf_get_name(0))
        vim.b.enable_formatter = false
        vim.notify('Permanently disable format on save')
    end)
    MAP.nnoremap('<leader>mu', function()
        unblacklist_file(vim.api.nvim_buf_get_name(0))
        vim.b.enable_formatter = true
        vim.notify('Remove current file from the blacklist')
    end)
    MAP.nnoremap('<leader>mc', function()
        local before = BLACKLIST.get()
        local after = gc_blacklist(before)
        vim.notify(string.format('GC blacklist: %d -> %d entries', #before, #after))
    end)
    MAP.nnoremap('<leader>ml',
                 function() require('settings.formatter_ui').toggle_quick_menu(BLACKLIST.get()) end)
end

function M.format_document()
    if not vim.b.enable_formatter then return end

    if is_blacklisted_file(vim.api.nvim_buf_get_name(0)) then return end

    vim.lsp.buf.formatting_sync()
end

return M
