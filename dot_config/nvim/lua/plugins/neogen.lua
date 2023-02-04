return { -- A better annotation generator. Supports multiple languages and annotation conventions.
    'danymat/neogen',
    cmd = 'Neogen',
    config = function()
        require('neogen').setup { enabled = true }
    end,
    dependencies = 'nvim-treesitter/nvim-treesitter',
}
