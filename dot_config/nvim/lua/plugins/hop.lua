return { -- Neovim motions on speed!
    'phaazon/hop.nvim',
    keys = {
        {
            '<Leader>w',
            function()
                require('hop').hint_words { direction = require('hop.hint').HintDirection.AFTER_CURSOR }
            end,
            desc = 'Hop: Annotate all words after cursor in the current window with key sequences.',
        },
        {
            '<Leader>b',
            function()
                require('hop').hint_words { direction = require('hop.hint').HintDirection.BEFORE_CURSOR }
            end,
            desc = 'Hop: Annotate all words before cursor in the current window with key sequences.',
        },
    },
    config = function()
        require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }
    end,
}
