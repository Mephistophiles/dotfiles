local cache_path = vim.fn.stdpath 'cache'
local cache_file = cache_path .. '/formatter_blacklist.msgpack'

local M = {}

local lsp_formatting = function(bufnr)
    vim.lsp.buf.format {
        filter = function(clients)
            return vim.tbl_filter(function(client)
                return client.name == 'null-ls'
            end, clients)
        end,
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
    M.setup_formatter()
    vim.keymap.set('n', '<leader>m', function()
        if vim.b.disable_formatter then
            vim.b.disable_formatter = false
            vim.notify 'Enable format on save'
        else
            vim.b.disable_formatter = true
            vim.notify 'Disable format on save'
        end
    end)

    vim.keymap.set('n', '<leader>mb', function()
        blacklist_file(vim.api.nvim_buf_get_name(0))
        vim.b.disable_formatter = true
        vim.notify 'Permanently disable format on save'
    end)
    vim.keymap.set('n', '<leader>mu', function()
        unblacklist_file(vim.api.nvim_buf_get_name(0))
        vim.b.disable_formatter = false
        vim.notify 'Remove current file from the blacklist'
    end)
    vim.keymap.set('n', '<leader>mc', function()
        local before = BLACKLIST.get()
        local after = gc_blacklist(before)
        vim.notify(string.format('GC blacklist: %d -> %d entries', #before, #after))
    end)
    vim.keymap.set('n', '<leader>ml', function()
        require('settings.formatter_ui').toggle_quick_menu(BLACKLIST.get())
    end)
end

function M._handler(err, result, ctx)
    if err ~= nil then
        return
    end
    if result == nil then
        return
    end
    if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
        vim.fn.bufload(ctx.bufnr)
        vim.api.nvim_buf_set_var(
            ctx.bufnr,
            'format_changedtick',
            vim.api.nvim_buf_get_var(ctx.bufnr, 'changedtick')
        )
    elseif
        vim.api.nvim_buf_get_var(ctx.bufnr, 'format_changedtick')
            ~= vim.api.nvim_buf_get_var(ctx.bufnr, 'changedtick')
        or vim.startswith(vim.api.nvim_get_mode().mode, 'i')
    then
        return
    end

    vim.lsp.util.apply_text_edits(result, ctx.bufnr, 'utf-16')
    if ctx.bufnr == vim.api.nvim_get_current_buf() then
        vim.cmd [[update]]
    end
end

--- @class Options
--- @field filter function
--- @field bufnr number
--- @param tbl Options
function FORMAT_POLYFILL(tbl)
    local clients = vim.tbl_values(vim.lsp.buf_get_clients())
    clients = tbl.filter(clients)

    vim.b.format_changedtick = vim.b.changedtick

    local params = vim.lsp.util.make_formatting_params {}
    local method = 'textDocument/formatting'
    local timeout_ms = 2000

    for _, client in ipairs(clients) do
        local result = client.request_sync(method, params, timeout_ms, tbl.bufnr) or {}
        M._handler(result.err, result.result, { client_id = client.id, bufnr = tbl.bufnr })
    end
end

function M.setup_formatter()
    assert(
        vim.lsp.buf.format == nil or vim.lsp.buf.format == FORMAT_POLYFILL,
        'Remove this override'
    )

    vim.lsp.buf.format = FORMAT_POLYFILL
end

function M.format_document(bufnr)
    if vim.b.disable_formatter then
        return
    end

    if is_blacklisted_file(vim.api.nvim_buf_get_name(0)) then
        return
    end

    lsp_formatting(bufnr)
end

return M
