local supported_languages = {
    'bash',
    'c',
    'cmake',
    'diff',
    'doxygen',
    'fish',
    'gitcommit',
    'go',
    'json',
    'lua',
    'log',
    'make',
    'markdown',
    'markdown_inline',
    'norg',
    'python',
    'query',
    'regex',
    'rust',
    'vim',
    'vimdoc',
    'yaml',
}

return {
    { -- Nvim Treesitter configurations and abstraction layer
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        branch = 'main',
        -- ft = supported_languages,
        opts = {
            install_dir = vim.fn.stdpath 'data' .. '/site',
        },
        init = function()
            vim.api.nvim_create_autocmd('User', {
                pattern = 'VeryLazy',
                callback = function()
                    require('nvim-treesitter').install(supported_languages)
                end,
            })
            vim.api.nvim_create_autocmd('User', {
                pattern = 'TSUpdate',
                callback = function()
                    require('nvim-treesitter.parsers').log = {
                        install_info = {
                            url = 'https://github.com/Tudyx/tree-sitter-log',
                            files = { 'src/parser.c' },
                            revision = '62cfe307e942af3417171243b599cc7deac5eab9',
                        },
                    }
                end,
            })
            vim.api.nvim_create_autocmd('FileType', {
                pattern = supported_languages,
                callback = function()
                    -- syntax highlighting, provided by Neovim
                    vim.treesitter.start()
                    -- folds, provided by Neovim
                    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    -- indentation, provided by nvim-treesitter
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
        dependencies = {
            {
                'nvim-treesitter/nvim-treesitter-context',
                opts = {
                    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
                    max_lines = 15, -- How many lines the window should span. Values <= 0 mean no limit.
                    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                    line_numbers = true,
                    multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
                    trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                    mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
                    -- Separator between context and content. Should be a single character string, like '-'.
                    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                    separator = nil,
                    zindex = 20, -- The Z-index of the context window
                },
            },
        },
    },
}
