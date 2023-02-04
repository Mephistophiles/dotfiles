return { -- Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more
    'numToStr/Comment.nvim',
    event = { 'VeryLazy', 'InsertCharPre' },
    config = function()
        require('Comment').setup()
    end,
}
