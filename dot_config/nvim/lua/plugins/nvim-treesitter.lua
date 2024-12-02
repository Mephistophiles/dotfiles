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
    'yaml',
}

return {
    { -- Nvim Treesitter configurations and abstraction layer
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        ft = supported_languages,
        config = function()
            local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
            parser_config.log = {
                install_info = {
                    url = 'https://github.com/Tudyx/tree-sitter-log', -- local path or git repo
                    files = { 'src/parser.c' }, -- note that some parsers also require src/scanner.c or src/scanner.cc
                    -- optional entries:
                    revision = '62cfe307e942af3417171243b599cc7deac5eab9', -- default branch in case of git repo if different from master
                    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
                    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
                },
                filetype = 'log', -- if filetype does not match the parser name
            }
            require('nvim-treesitter').setup()
            require('nvim-treesitter.configs').setup {
                -- ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
                ensure_installed = supported_languages,
                ignore_install = {}, -- List of parsers to ignore installing
                modules = {},
                sync_install = true,
                auto_install = true,
                highlight = {
                    enable = true, -- false will disable the whole extension
                    disable = {}, -- list of language that will be disabled
                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = {}, -- Required since TS highlighter doesn't support all syntax features (conceal)
                },
                query_linter = {
                    enable = true,
                    use_virtual_text = true,
                    lint_events = { 'BufWrite', 'CursorHold' },
                },
            }

            vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
            vim.wo.foldmethod = 'expr'
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
            {
                'Wansmer/sibling-swap.nvim',
                opts = {
                    keymaps = {
                        ['<C-.>'] = 'swap_with_right',
                        ['<C-,>'] = 'swap_with_left',
                        ['<space>.'] = 'swap_with_right_with_opp',
                        ['<space>,'] = 'swap_with_left_with_opp',
                    },
                },
            },
        },
    },
    { -- Treesitter playground integrated into Neovim
        'nvim-treesitter/playground',
        cmd = 'TSPlaygroundToggle',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },
}
