_G.dd = function(...)
    Snacks.debug.inspect(...)
end
_G.bt = function()
    Snacks.debug.backtrace()
end

_G.RELOAD = function(...)
    return require('plenary.reload').reload_module(...)
end

_G.R = function(name)
    _G.RELOAD(name)
    return require(name)
end

--- Get nvim command
---@param cmd string
---@return string
_G.CMD = function(cmd)
    return '<cmd>' .. cmd .. '<cr>'
end

_G.MAP_CLEANUPS = {
    CMD 'nohlsearch',
    CMD 'call clearmatches()',
}
