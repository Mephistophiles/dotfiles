return {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = {
        select = {
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V', -- linewise
                -- ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true of false
            include_surrounding_whitespace = false,
        },
        move = {
            -- whether to set jumps in the jumplist
            set_jumps = true,
        },
    },
    keys = {
        {
            mode = { 'x', 'o' },
            'am',
            function()
                require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
            end,
            desc = 'Treesitter: select outer function',
        },
        {
            mode = { 'x', 'o' },
            'im',
            function()
                require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
            end,
            desc = 'Treesitter: select inner function',
        },
        {
            mode = { 'x', 'o' },
            'ac',
            function()
                require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
            end,
            desc = 'Treesitter: select outer class',
        },
        {
            mode = { 'x', 'o' },
            'ic',
            function()
                require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
            end,
            desc = 'Treesitter: select inner class',
        },
        {
            mode = { 'x', 'o' },
            'as',
            function()
                require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
            end,
            desc = 'Treesitter: select local scope',
        },
        {
            mode = { 'n' },
            '<leader>a',
            function()
                require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner'
            end,
            desc = 'Treesitter: swap paramer inner',
        },
        {
            mode = { 'n' },
            '<leader>A',
            function()
                require('nvim-treesitter-textobjects.swap').swap_previous '@parameter.outer'
            end,
            desc = 'Treesitter: swap paramer outer',
        },
        {
            mode = { 'n', 'x', 'o' },
            ']m',
            function()
                require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
            end,
            desc = 'Treesitter: move function outer',
        },
        {
            mode = { 'n', 'x', 'o' },
            '[m',
            function()
                require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
            end,
            desc = 'Treesitter: move function outer',
        },
        {
            mode = { 'n', 'x', 'o' },
            ']]',
            function()
                require('nvim-treesitter-textobjects.move').goto_next_start('@statement.outer', 'textobjects')
            end,
            desc = 'Treesitter: move statement',
        },
        {
            mode = { 'n', 'x', 'o' },
            '[[',
            function()
                require('nvim-treesitter-textobjects.move').goto_previous_start('@statement.outer', 'textobjects')
            end,
            desc = 'Treesitter: move statement',
        },
        -- You can also pass a list to group multiple queries.
        {
            mode = { 'n', 'x', 'o' },
            ']o',
            function()
                require('nvim-treesitter-textobjects.move').goto_next_start(
                    { '@loop.inner', '@loop.outer' },
                    'textobjects'
                )
            end,
            desc = 'Treesitter: move loop',
        },
        {
            mode = { 'n', 'x', 'o' },
            '[o',
            function()
                require('nvim-treesitter-textobjects.move').goto_previous_start(
                    { '@loop.inner', '@loop.outer' },
                    'textobjects'
                )
            end,
            desc = 'Treesitter: move loop',
        },
        -- You can also use captures from other query groups like `locals.scm` or `folds.scm`
        {
            mode = { 'n', 'x', 'o' },
            ']s',
            function()
                require('nvim-treesitter-textobjects.move').goto_next_start('@local.scope', 'locals')
            end,
            desc = 'Treesitter: move scope',
        },
        {
            mode = { 'n', 'x', 'o' },
            '[s',
            function()
                require('nvim-treesitter-textobjects.move').goto_previous_start('@local.scope', 'locals')
            end,
            desc = 'Treesitter: move scope',
        },
        {
            mode = { 'n', 'x', 'o' },
            ']z',
            function()
                require('nvim-treesitter-textobjects.move').goto_next_start('@fold', 'folds')
            end,
            desc = 'Treesitter: move fold',
        },
        {
            mode = { 'n', 'x', 'o' },
            '[z',
            function()
                require('nvim-treesitter-textobjects.move').goto_previous_start('@fold', 'folds')
            end,
            desc = 'Treesitter: move fold',
        },

        -- Go to either the start or the end, whichever is closer.
        -- Use if you want more granular movements
        {
            mode = { 'n', 'x', 'o' },
            ']d',
            function()
                require('nvim-treesitter-textobjects.move').goto_next('@conditional.outer', 'textobjects')
            end,
            desc = 'Treesitter: move conditional outer',
        },
        {
            mode = { 'n', 'x', 'o' },
            '[d',
            function()
                require('nvim-treesitter-textobjects.move').goto_previous('@conditional.outer', 'textobjects')
            end,
            desc = 'Treesitter: move conditional outer',
        },

        {
            mode = { 'n', 'x', 'o' },
            ']p',
            function()
                require('nvim-treesitter-textobjects.move').goto_next_start('@parameter.outer', 'textobjects')
            end,
            desc = 'Treesitter: move parameter',
        },
        {
            mode = { 'n', 'x', 'o' },
            '[p',
            function()
                require('nvim-treesitter-textobjects.move').goto_previous_start('@parameter.outer', 'textobjects')
            end,
            desc = 'Treesitter: move parameter',
        },
    },
    lazy = true,
}
