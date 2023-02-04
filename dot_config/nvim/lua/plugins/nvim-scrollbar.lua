return { -- Extensible Neovim Scrollbar
    'petertriho/nvim-scrollbar',
    event = 'VeryLazy',
    config = function()
        require('scrollbar').setup()
    end,
}
