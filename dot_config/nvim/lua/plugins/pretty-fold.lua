return { -- Foldtext customization in Neovim
    'anuvyklack/pretty-fold.nvim',
    event = 'VeryLazy',
    config = function()
        require('pretty-fold').setup {}
    end,
}
