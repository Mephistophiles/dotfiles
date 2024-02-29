local cache_path = vim.fn.stdpath 'cache'
local cache_file = cache_path .. '/formatter_ignorelist.msgpack'

--- @class Ignorelist
local M = {}

function M.ignore_file(file)
    local ignorelist = M.get()

    if not vim.tbl_contains(ignorelist, file) then
        table.insert(ignorelist, file)
    end

    M.set(ignorelist)
end

function M.gc_ignorelist(ignorelist)
    ignorelist = vim.tbl_filter(function(file)
        local st = vim.loop.fs_stat(file)
        return st ~= nil -- and (st.type == 'file' or st.type == 'directory')
    end, ignorelist)

    M.set(ignorelist)

    return ignorelist
end

function M.unignore_file(file)
    local ignorelist = M.get()

    ignorelist = vim.tbl_filter(function(f)
        return f ~= file
    end, ignorelist)

    M.set(ignorelist)
end

function M.is_ignored_file(file)
    local denylist = M.get()

    for _, pattern in ipairs(denylist) do
        local pattern_regex = vim.regex(vim.fn.glob2regpat(pattern))
        if pattern_regex:match_str(file) then
            return true
        end
    end

    return false
end

local function create_empty()
    return {}
end

--- Gets the current ignorelist
--- @return Ignorelist
function M.get()
    local opened, cache = pcall(vim.fn.readfile, cache_file, 'b')
    if not opened then
        return create_empty()
    end
    local parsed, ret = pcall(vim.fn.msgpackparse, cache)

    if parsed then
        return ret
    else
        vim.loop.fs_unlink(cache_file)
        return create_empty()
    end
end

--- Override current ignorelist
--- @param ignorelist Ignorelist
function M.set(ignorelist)
    vim.fn.writefile(vim.fn.msgpackdump(ignorelist), cache_file, 'b')
end

return M
