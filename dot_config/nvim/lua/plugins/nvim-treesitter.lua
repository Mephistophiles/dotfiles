return {
    { -- Nvim Treesitter configurations and abstraction layer
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = 'VeryLazy',
        config = function()
            require('nvim-treesitter').setup()
            -- alt+<space>, alt+p -> swap next
            -- alt+<backspace>, alt+p -> swap previous
            local swap_next, swap_prev = (function()
                local swap_objects = {
                    p = '@parameter.inner',
                    f = '@function.outer',
                    e = '@element',

                    -- Not ready, but I think it's my fault :)
                    -- v = "@variable",
                }

                local n, p = {}, {}
                for key, obj in pairs(swap_objects) do
                    n[string.format('<M-Space><M-%s>', key)] = obj
                    p[string.format('<M-BS><M-%s>', key)] = obj
                end

                return n, p
            end)()

            require('nvim-treesitter.configs').setup {
                -- ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
                ensure_installed = {
                    'bash',
                    'c',
                    'cmake',
                    'fish',
                    'go',
                    'haskell',
                    'json',
                    'lua',
                    'make',
                    'markdown',
                    'markdown_inline',
                    'org',
                    'python',
                    'query',
                    'regex',
                    'rust',
                    'vim',
                },
                ignore_install = {}, -- List of parsers to ignore installing
                highlight = {
                    enable = true, -- false will disable the whole extension
                    disable = {}, -- list of language that will be disabled
                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = { 'org' }, -- Required since TS highlighter doesn't support all syntax features (conceal)
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
                matchup = {
                    enable = true,
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
                        enable = true,
                        swap_next = swap_next,
                        swap_previous = swap_prev,
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
                rainbow = {
                    enable = true,
                    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
                    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                    max_file_lines = nil, -- Do not enable for files with more than n lines, int
                    -- colors = {}, -- table of hex strings
                    -- termcolors = {} -- table of colour name strings
                },
                refactor = {
                    highlight_definitions = {
                        enable = true,
                        -- Set to false if you have an `updatetime` of ~100.
                        clear_on_cursor_move = true,
                    },
                    smart_rename = {
                        enable = true,
                        keymaps = {
                            smart_rename = '<leader>rn',
                        },
                    },
                    navigation = {
                        enable = true,
                        keymaps = {
                            goto_definition = 'gd',
                            list_definitions = 'gnd',
                            list_definitions_toc = 'gO',
                            goto_next_usage = '<a-*>',
                            goto_previous_usage = '<a-#>',
                        },
                    },
                },
            }

            vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
            vim.wo.foldmethod = 'expr'
            vim.cmd 'TSEnable highlight'
        end,
        dependencies = {
            { 'HiPhish/nvim-ts-rainbow2' },
            'nvim-treesitter/nvim-treesitter-textobjects',
            {
                'mfussenegger/nvim-ts-hint-textobject',
                keys = {
                    {
                        'm',
                        '<C-U>:lua require("tsht").nodes()<cr>',
                        mode = 'o',
                        silent = true,
                        desc = 'Treesitter: Show treesitter select hints',
                    },
                    {
                        'm',
                        CMD 'lua require("tsht").nodes()',
                        mode = 'v',
                        silent = true,
                        desc = 'Treesitter: Show treesitter select hints',
                    },
                },
            },
            {
                'nvim-treesitter/nvim-treesitter-refactor',
            },
            {
                'andymass/vim-matchup',
                init = function()
                    vim.g.matchup_matchparen_offscreen = { method = 'popup' }
                end,
            },
        },
    },
    { -- Treesitter playground integrated into Neovim
        'nvim-treesitter/playground',
        cmd = 'TSPlaygroundToggle',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },
}