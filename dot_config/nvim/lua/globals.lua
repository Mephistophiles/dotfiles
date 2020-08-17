P = function(v)
    print(vim.inspect(v))
    return v
end

RELOAD = function(...) return require('plenary.reload').reload_module(...) end

R = function(name)
    RELOAD(name)
    return require(name)
end

MAP_CLEANUPS = {'<CMD>noh<CR>', '<CMD>call clearmatches()<CR>', '<CMD>lua vim.notify.dismiss()<CR>'}

local success
success, MAP = pcall(require, 'mapx')

if not success then
    MAP = setmetatable({}, {
        __index = function() return function() print('MAPPING is not supported') end end,
    })
end
