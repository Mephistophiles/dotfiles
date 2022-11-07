local util = require 'vim.lsp.util'

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
    M.setup_formatter()
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

function M._handler(err, result, ctx)
    if err ~= nil then
        return
    end
    if result == nil then
        return
    end
    if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
        vim.fn.bufload(ctx.bufnr)
        vim.api.nvim_buf_set_var(ctx.bufnr, 'format_changedtick', vim.api.nvim_buf_get_var(ctx.bufnr, 'changedtick'))
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

---@private
---@return table {start={row, col}, end={row, col}} using (1, 0) indexing
local function range_from_selection()
    -- TODO: Use `vim.region()` instead https://github.com/neovim/neovim/pull/13896

    -- [bufnum, lnum, col, off]; both row and column 1-indexed
    local start = vim.fn.getpos 'v'
    local end_ = vim.fn.getpos '.'
    local start_row = start[2]
    local start_col = start[3]
    local end_row = end_[2]
    local end_col = end_[3]

    -- A user can start visual selection at the end and move backwards
    -- Normalize the range to start < end
    if start_row == end_row and end_col < start_col then
        end_col, start_col = start_col, end_col
    elseif end_row < start_row then
        start_row, end_row = end_row, start_row
        start_col, end_col = end_col, start_col
    end
    return {
        ['start'] = { start_row, start_col - 1 },
        ['end'] = { end_row, end_col - 1 },
    }
end

--- Formats a buffer using the attached (and optionally filtered) language
--- server clients.
---
--- @param options table|nil Optional table which holds the following optional fields:
---     - formatting_options (table|nil):
---         Can be used to specify FormattingOptions. Some unspecified options will be
---         automatically derived from the current Neovim options.
---         @see https://microsoft.github.io/language-server-protocol/specification#textDocument_formatting
---     - timeout_ms (integer|nil, default 1000):
---         Time in milliseconds to block for formatting requests. No effect if async=true
---     - bufnr (number|nil):
---         Restrict formatting to the clients attached to the given buffer, defaults to the current
---         buffer (0).
---     - filter (function|nil):
---         Predicate to filter clients used for formatting. Receives the list of clients attached
---         to bufnr as the argument and must return the list of clients on which to request
---         formatting. Example:
---
---         <pre>
---         -- Never request typescript-language-server for formatting
---         vim.lsp.buf.format {
---           filter = function(clients)
---             return vim.tbl_filter(
---               function(client) return client.name ~= "tsserver" end,
---               clients
---             )
---           end
---         }
---         </pre>
---
---     - async boolean|nil
---         If true the method won't block. Defaults to false.
---         Editing the buffer while formatting asynchronous can lead to unexpected
---         changes.
---
---     - id (number|nil):
---         Restrict formatting to the client with ID (client.id) matching this field.
---     - name (string|nil):
---         Restrict formatting to the client with name (client.name) matching this field.
---     - range (table|nil) Range to format.
---         Table must contain `start` and `end` keys with {row, col} tuples using
---         (1,0) indexing.
---         Defaults to current selection in visual mode
---         Defaults to `nil` in other modes, formatting the full buffer
function FORMAT_POLYFILL(options)
    options = options or {}
    local bufnr = options.bufnr or vim.api.nvim_get_current_buf()
    local clients = vim.lsp.buf_get_clients(bufnr)

    if options.filter then
        clients = options.filter(clients)
    elseif options.id then
        clients = vim.tbl_filter(function(client)
            return client.id == options.id
        end, clients)
    elseif options.name then
        clients = vim.tbl_filter(function(client)
            return client.name == options.name
        end, clients)
    end

    clients = vim.tbl_filter(function(client)
        return client.supports_method 'textDocument/formatting'
    end, clients)

    if #clients == 0 then
        vim.notify '[LSP] Format request failed, no matching language servers.'
    end

    local mode = vim.api.nvim_get_mode().mode
    local range = options.range
    if not range and mode == 'v' or mode == 'V' then
        range = range_from_selection()
    end

    ---@private
    local function set_range(client, params)
        if range then
            local range_params = util.make_given_range_params(range.start, range['end'], bufnr, client.offset_encoding)
            params.range = range_params.range
        end
        return params
    end

    local method = range and 'textDocument/rangeFormatting' or 'textDocument/formatting'
    if options.async then
        local do_format
        do_format = function(idx, client)
            if not client then
                return
            end
            local params = set_range(client, util.make_formatting_params(options.formatting_options))
            client.request(method, params, function(...)
                local handler = client.handlers[method] or vim.lsp.handlers[method]
                handler(...)
                do_format(next(clients, idx))
            end, bufnr)
        end
        do_format(next(clients))
    else
        local timeout_ms = options.timeout_ms or 1000
        for _, client in pairs(clients) do
            local params = set_range(client, util.make_formatting_params(options.formatting_options))
            local result, err = client.request_sync(method, params, timeout_ms, bufnr)
            if result and result.result then
                util.apply_text_edits(result.result, bufnr, client.offset_encoding)
            elseif err then
                vim.notify(string.format('[LSP][%s] %s', client.name, err), vim.log.levels.WARN)
            end
        end
    end
end

function M.setup_formatter()
    assert(vim.lsp.buf.format == nil or vim.lsp.buf.format == FORMAT_POLYFILL, 'Remove this override')

    vim.lsp.buf.format = FORMAT_POLYFILL
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
