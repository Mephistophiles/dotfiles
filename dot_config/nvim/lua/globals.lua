P = function(v)
    print(vim.inspect(v))
    return v
end

RELOAD = function(...)
    return require('plenary.reload').reload_module(...)
end

R = function(name)
    RELOAD(name)
    return require(name)
end

--- Get nvim command
---@param cmd string
---@return string
function CMD(cmd)
    return '<cmd>' .. cmd .. '<cr>'
end

MAP_CLEANUPS = {
    CMD 'nohlsearch',
    CMD 'call clearmatches()',
}
