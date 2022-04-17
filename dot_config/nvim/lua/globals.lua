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

MAP_CLEANUPS = {
    '<CMD>noh<CR>',
    '<CMD>call clearmatches()<CR>',
    '<CMD>lua vim.notify.dismiss()<CR>',
}
