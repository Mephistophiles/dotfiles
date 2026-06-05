vim.g.did_load_filetypes = false
vim.g.do_filetype_lua = true

vim.filetype.add {
    extension = {
        bst = 'yaml',
        log = 'log',
        tl = 'teal',
    },
    filename = {
        ['Config.in'] = 'kconfig',
        ['Justfile'] = 'make',
    },
}
