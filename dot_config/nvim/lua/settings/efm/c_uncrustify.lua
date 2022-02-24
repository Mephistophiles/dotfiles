local cfgpath = vim.fn.stdpath('config')

return {
	formatCommand = string.format('uncrustify -C %s/uncrustify.cfg -lc', cfgpath),
	formatStdin = true,
}
