local cache_file = (function()
    local value = nil

    return function()
        if value == nil then
            local cache_path = vim.fn.stdpath 'cache'
            value = vim.fs.joinpath(cache_path, '/formatter_ignorelist.msgpack')
        end

        return value
    end
end)()

local M = {}

--- @class Ignorelist
M.set = function(ignorelist)
    vim.fn.writefile(vim.fn.msgpackdump(ignorelist), cache_file(), 'b')
end

M.ignore_file = function(file)
    local ignorelist = M.get()

    if not vim.tbl_contains(ignorelist, file) then
        table.insert(ignorelist, file)
    end

    M.set(ignorelist)
end

M.gc_ignorelist = function(ignorelist)
    ignorelist = vim.tbl_filter(function(file)
        local st = vim.loop.fs_stat(file)
        return st ~= nil -- and (st.type == 'file' or st.type == 'directory')
    end, ignorelist)

    M.set(ignorelist)

    return ignorelist
end
M.unignore_file = function(file)
    local ignorelist = M.get()

    ignorelist = vim.tbl_filter(function(f)
        return f ~= file
    end, ignorelist)

    M.set(ignorelist)
end

M.is_ignored_file = function(file)
    local denylist = M.get()

    for _, pattern in ipairs(denylist) do
        local pattern_regex = vim.regex(vim.fn.glob2regpat(pattern))
        if pattern_regex:match_str(file) then
            return true
        end
    end

    return false
end

M.get = function()
    local opened, cache = pcall(vim.fn.readfile, cache_file(), 'b')
    if not opened then
        return {}
    end
    local parsed, ret = pcall(vim.fn.msgpackparse, cache)

    if parsed then
        return ret
    else
        vim.loop.fs_unlink(cache_file())
        return {}
    end
end

return M
