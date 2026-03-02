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
    'python',
    'query',
    'regex',
    'rust',
    'vim',
    'vimdoc',
    'yaml',
}

local ts_loaded = false

local function ts_load(args)
    require('lazy').load {
        plugins = {
            'nvim-treesitter-context',
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

    -- folds, provided by Neovim
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- indentation, provided by nvim-treesitter
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

local function ts_start(args)
    if not ts_loaded then
        ts_load(args)
        ts_loaded = true
    end

    local ts = require 'nvim-treesitter'
    local lang = vim.treesitter.language.get_lang(args.match)
    if vim.list_contains(ts.get_available(), lang) then
        if not vim.list_contains(ts.get_installed(), lang) then
            ts.install(lang):wait()
        end
        vim.treesitter.start(args.buf)
        require('rainbow-delimiters').enable(args.buf)
    end
end

return {
    -- Nvim Treesitter configurations and abstraction layer
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = true,
    branch = 'main',
    opts = {
        install_dir = vim.fn.stdpath 'data' .. '/site',
    },
    init = function()
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
            callback = function(args)
                vim.defer_fn(function()
                    ts_start(args)
                end, 500)
            end,
            desc = 'Enable nvim-treesitter and install parser if not installed',
        })
    end,
}
