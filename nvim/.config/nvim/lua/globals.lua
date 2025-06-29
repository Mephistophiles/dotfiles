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
