return { -- Foldtext customization in Neovim
    'anuvyklack/pretty-fold.nvim',
    event = 'VeryLazy',
    config = function()
        require('pretty-fold').setup {}
        require('fold-preview').setup()
    end,
    dependencies = { 'anuvyklack/nvim-keymap-amend', 'anuvyklack/fold-preview.nvim' },
}
