return { -- A faster version of filetype.vim
    'nathom/filetype.nvim',
    init = function()
        vim.g.did_load_filetypes = 1
    end,
    config = function()
        require('filetype').setup {
            overrides = {
                extensions = {
                    tl = 'teal',
                },
                literal = {
                    ['Config.in'] = 'kconfig',
                },
            },
        }
    end,
}
