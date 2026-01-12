local supported_languages = {
    'bash',
    'c',
    'cpp',
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
    -- Nvim Treesitter configurations and abstraction layer
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = true,
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

                require('lazy').load {
                    plugins = {
                        'nvim-treesitter-context',
                        'nvim-treesitter-textobjects',
                        'rainbow-delimiters.nvim',
                    },
                }

                require('rainbow-delimiters.setup').setup {
                    strategy = {
                        [''] = 'rainbow-delimiters.strategy.global',
                    },
                    query = {
                        [''] = 'rainbow-delimiters',
                    },
                    highlight = {
                        'RainbowDelimiterRed',
                        'RainbowDelimiterYellow',
                        'RainbowDelimiterBlue',
                        'RainbowDelimiterOrange',
                        'RainbowDelimiterGreen',
                        'RainbowDelimiterViolet',
                        'RainbowDelimiterCyan',
                    },
                }
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
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                -- indentation, provided by nvim-treesitter
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                require('rainbow-delimiters').enable(0)
            end,
        })
    end,
}
