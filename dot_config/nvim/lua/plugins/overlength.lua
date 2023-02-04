return { -- A small Neovim plugin to highlight too long lines
    'lcheylus/overlength.nvim',
    config = function()
        require('overlength').setup {
            disable_ft = {
                'NvimTree',
                'Telescope',
                'WhichKey',
                'diff',
                'gitcommit',
                'help',
                'json',
                'man',
                'packer',
                'qf',
            },
        }
    end,
}
