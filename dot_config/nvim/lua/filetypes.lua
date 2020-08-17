vim.cmd [[
augroup ft_json
    au!

    au BufRead,BufNewFile *.dm,*config.default setlocal filetype=json sw=4 ts=4 expandtab
    au BufRead,BufNewFile *config.default let b:formatter_sort_keys = 1
augroup END
]]
