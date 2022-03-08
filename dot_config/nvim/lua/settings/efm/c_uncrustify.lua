local cfgpath = vim.fn.stdpath('config')

return {
    formatCommand = string.format('uncrustify -c %s/uncrustify.cfg -lc', cfgpath),
    formatStdin = true,
}
