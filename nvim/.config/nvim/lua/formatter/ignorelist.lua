local M = {}

local function state_file()
    return vim.fs.joinpath(vim.fn.stdpath 'state', 'formatter_ignorelist.msgpack')
end

local function read_list(path)
    local opened, contents = pcall(vim.fn.readfile, path, 'b')
    if not opened then
        return nil
    end
    local parsed, entries = pcall(vim.fn.msgpackparse, contents)
    if parsed and type(entries) == 'table' and vim.islist(entries) then
        for _, entry in ipairs(entries) do
            if type(entry) ~= 'string' then
                return nil
            end
        end
        return entries
    end
    vim.notify('Invalid formatter ignorelist: ' .. path, vim.log.levels.WARN)
end

function M.set(entries)
    vim.fn.mkdir(vim.fn.stdpath 'state', 'p', '0700')
    vim.fn.writefile(vim.fn.msgpackdump(entries), state_file(), 'b')
end

function M.get()
    local path = state_file()
    if vim.uv.fs_stat(path) then
        return read_list(path) or {}
    end

    -- Migrate existing settings without deleting the old cache file.
    local legacy = vim.fs.joinpath(vim.fn.stdpath 'cache', 'formatter_ignorelist.msgpack')
    local entries = read_list(legacy)
    if entries then
        M.set(entries)
    end
    return entries or {}
end

function M.ignore_file(file)
    local entries = M.get()
    if not vim.list_contains(entries, file) then
        table.insert(entries, file)
        M.set(entries)
    end
end

function M.unignore_file(file)
    M.set(vim.tbl_filter(function(entry)
        return entry ~= file
    end, M.get()))
end

function M.gc_ignorelist(entries)
    entries = vim.tbl_filter(function(entry)
        -- Patterns may deliberately match files which do not exist yet.
        return entry:find('[*?%[]') ~= nil or vim.uv.fs_stat(entry) ~= nil
    end, entries)
    M.set(entries)
    return entries
end

function M.is_ignored_file(file)
    for _, pattern in ipairs(M.get()) do
        if pattern == file or vim.regex(vim.fn.glob2regpat(pattern)):match_str(file) then
            return true
        end
    end
    return false
end

return M
