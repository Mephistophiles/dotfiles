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

local supported_fts = vim.tbl_map(function(ft)
    return 'FileType ' .. ft
end, supported_languages)

return {
    { -- Nvim Treesitter configurations and abstraction layer
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = supported_fts,
        config = function()
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
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = 'gnn',
                        node_incremental = 'grn',
                        scope_incremental = 'grc',
                        node_decremental = 'grm',
                    },
                },
                textobjects = {
                    select = {
                        enable = true,

                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,

                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['aC'] = '@condition.outer',
                            ['iC'] = '@condition.inner',
                            ['ac'] = '@call.outer',
                            ['ic'] = '@call.inner',
                            ['ai'] = '@class.outer',
                            ['ii'] = '@class.inner',
                            ['al'] = '@loop.outer',
                            ['il'] = '@loop.inner',
                            ['ap'] = '@parameter.outer',
                            ['ip'] = '@parameter.inner',
                            ['i<space>'] = '@statement.outer',
                        },
                    },
                    swap = {
                        enable = false,
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            [']]'] = '@block.outer',
                            [']f'] = '@function.outer',
                            [']p'] = '@parameter.outer',
                        },
                        goto_next_end = {
                            [']F'] = '@function.outer',
                            [']P'] = '@parameter.outer',
                        },
                        goto_previous_start = {
                            ['[['] = '@block.outer',
                            ['[f'] = '@function.outer',
                            ['[p'] = '@parameter.outer',
                        },
                        goto_previous_end = {
                            ['[F'] = '@function.outer',
                            ['[P'] = '@parameter.outer',
                        },
                    },
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
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
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
