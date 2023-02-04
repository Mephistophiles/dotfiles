return { -- Hlsearch Lens for Neovim
    'kevinhwang91/nvim-hlslens',
    event = 'VeryLazy',
    config = function()
        -- require('hlslens').setup()
        require('scrollbar.handlers.search').setup {} -- use it instead of hlsens
    end,
}
