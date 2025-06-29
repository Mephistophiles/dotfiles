vim.g.did_load_filetypes = false
vim.g.do_filetype_lua = true

vim.filetype.add {
    extension = {
        tl = 'teal',
        log = 'log',
    },
    filename = {
        ['Config.in'] = 'kconfig',
        ['Justfile'] = 'make',
    },
}
