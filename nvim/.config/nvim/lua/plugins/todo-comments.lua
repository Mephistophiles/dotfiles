return { -- Highlight, list and search todo comments in your projects
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    dependencies = 'nvim-lua/plenary.nvim',
    opts = {
        highlight = { pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]] },
        search = { pattern = [[\b(KEYWORDS)(\([^\)]*\))?:]] },
    },
}
