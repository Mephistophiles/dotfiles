require('lazy').setup {
    { -- A faster version of filetype.vim
        'nathom/filetype.nvim',
        init = function()
            vim.g.did_load_filetypes = 1
        end,
        config = function()
            require('settings.filetypes').config()
        end,
    },

    { -- Statusline written in pure lua. Supports co-routines, functions and jobs.
        'tjdevries/express_line.nvim',
        event = 'VeryLazy',
        dependencies = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' },
        config = function()
            require('settings.express_line').config()
        end,
    },
    { -- A clean, dark Neovim theme written in Lua, with support for lsp, treesitter and lots of plugins. Includes additional themes for Kitty, Alacritty, iTerm and Fish.
        'folke/tokyonight.nvim',
        priority = 1000,
        init = function()
            vim.opt.background = 'dark'
            vim.opt.termguicolors = true
        end,
        config = function()
            require('tokyonight').setup {
                style = 'moon', -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
            }
            -- vim.cmd.colorscheme 'tokyonight-storm'
            vim.cmd.colorscheme 'tokyonight-moon'
        end,
    },
    { -- enable repeating supported plugin maps with "."
        'tpope/vim-repeat',
    },

    { -- Automatic indentation style detection for Neovim
        'NMAC427/guess-indent.nvim',
        config = function()
            require('guess-indent').setup {}
        end,
    },

    { -- Neovim plugin to stabilize window open/close events.
        'luukvbaal/stabilize.nvim',
        config = function()
            require('stabilize').setup()
        end,
    },

    { -- The superior project management solution for neovim.
        'ahmedkhalf/project.nvim',
        config = function()
            require('project_nvim').setup {
                detection_methods = { 'pattern' },
                patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn' },
            }
        end,
    },

    { -- (Neo)Vim plugin for automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
        'RRethy/vim-illuminate',
        event = 'CursorHold',
        config = function()
            local augroup = vim.api.nvim_create_augroup('IlluminatedAugroup', { clear = true })

            vim.api.nvim_create_autocmd('VimEnter', {
                group = augroup,
                pattern = '*',
                desc = 'Override highlight',
                callback = function()
                    vim.api.nvim_set_hl(0, 'illuminatedWord', { underline = true })
                    vim.api.nvim_set_hl(0, 'IlluminatedWordText', { underline = true })
                    vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { underline = true })
                    vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { underline = true, bold = true })
                end,
            })

            -- default configuration
            require('illuminate').configure {
                -- providers: provider used to get references in the buffer, ordered by priority
                providers = {
                    'lsp',
                    'treesitter',
                    'regex',
                },
                -- delay: delay in milliseconds
                delay = 100,
                -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
                filetypes_denylist = {
                    'dirvish',
                    'fugitive',
                },
                -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
                -- See `:help mode()` for possible values
                modes_denylist = { 'i', 't', 'nt', 'ntT' },
            }
        end,
    },

    { -- A fancy, configurable, notification manager for NeoVim
        'rcarriga/nvim-notify',
        config = function()
            local notify_fn = require 'notify'
            vim.notify = setmetatable({}, {
                __call = function(_, msg, level, opts)
                    if vim.g.nvim_notify_stack_trace and level and level >= vim.log.levels.WARN then
                        msg = msg .. '\n' .. debug.traceback('Trace', 2)
                    end

                    notify_fn(msg, level, opts)
                end,
                __index = function(_, key)
                    return notify_fn[key]
                end,
            })

            vim.keymap.set('n', '<leader>n', function()
                vim.g.nvim_notify_stack_trace = not vim.g.nvim_notify_stack_trace
                vim.notify(
                    'Stacktrace in notifications was ' .. (vim.g.nvim_notify_stack_trace and 'enabled' or 'disabled'),
                    vim.log.levels.INFO
                )
            end, { desc = 'Notifications: toggle stacktrace from warn and above' })
        end,
    },
    { -- Create key bindings that stick. WhichKey is a lua plugin for Neovim 0.5 that displays a popup with possible keybindings of the command you started typing.
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            require('which-key').setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end,
    },
    { -- Indent guides for Neovim
        'lukas-reineke/indent-blankline.nvim',
        event = 'VeryLazy',
        config = function()
            require('indent_blankline').setup {
                space_char_blankline = ' ',
                show_current_context = false,
                show_current_context_start = false,
            }
        end,
    },
    { -- Treesitter based structural search and replace plugin for Neovim.
        'cshuaimin/ssr.nvim',
        keys = {
            {
                '<leader>sr',
                function()
                    require('ssr').open()
                end,
                desc = 'SSR: Open popup',
            },
            {
                '<leader>sr',
                function()
                    require('ssr').open()
                end,
                'x',
                desc = 'SSR: Open popup',
            },
        },
        config = function()
            require('ssr').setup {
                min_width = 50,
                min_height = 5,
                keymaps = {
                    close = 'q',
                    next_match = 'n',
                    prev_match = 'N',
                    replace_all = '<leader><cr>',
                },
            }
        end,
    },

    { -- Extensible Neovim Scrollbar
        'petertriho/nvim-scrollbar',
        event = 'VeryLazy',
        config = function()
            require('scrollbar').setup()
        end,
    },

    { -- Hlsearch Lens for Neovim
        'kevinhwang91/nvim-hlslens',
        event = 'VeryLazy',
        config = function()
            -- require('hlslens').setup()
            require('scrollbar.handlers.search').setup {} -- use it instead of hlsens
        end,
    },

    { -- Clean window maximizing, terminal toggling, window/tmux pane movements and more!
        'declancm/windex.nvim',
        keys = {
            {
                '<leader>z',
                CMD "lua require('windex').toggle_nvim_maximize()",
                desc = 'Windex: Toggle maximizing the current window',
            },
        },
        config = function()
            require('windex').setup {
                default_keymaps = false,
            }
        end,
    },

    { -- a lua powered greeter like vim-startify / dashboard-nvim
        'goolord/alpha-nvim',
        cond = function()
            -- don't start when opening a file
            if vim.fn.argc() > 0 then
                return false
            end

            -- skip stdin
            if vim.fn.line2byte '$' ~= -1 then
                return false
            end

            -- Handle nvim -M
            if not vim.o.modifiable then
                return false
            end

            for _, arg in pairs(vim.v.argv) do
                -- whitelisted arguments
                -- always open
                if arg == '--startuptime' then
                    return true
                end

                -- blacklisted arguments
                -- always skip
                if
                    arg == '-b'
                    -- commands, typically used for scripting
                    or arg == '-c'
                    or vim.startswith(arg, '+')
                    or arg == '-S'
                then
                    return false
                end
            end

            return true
        end,
        dependencies = { 'kyazdani42/nvim-web-devicons' },
        config = function()
            require('alpha').setup(require('alpha.themes.startify').config)
        end,
    },

    { -- Neovim plugin introducing a new operators motions to quickly replace and exchange text.
        'gbprod/substitute.nvim',
        keys = {
            { 's', CMD "lua require('substitute').operator()", noremap = true },
            { 'ss', CMD "lua require('substitute').line()", noremap = true },
            { 'S', CMD "lua require('substitute').eol()", noremap = true },
            { 's', CMD "lua require('substitute').visual()", 'x', noremap = true },
            { '<leader>s', CMD "lua require('substitute.range').operator()", noremap = true },
            { '<leader>s', CMD "lua require('substitute.range').visual()", 'x', noremap = true },
            { '<leader>ss', CMD "lua require('substitute.range').word()", noremap = true },
            { 'sx', CMD "lua require('substitute.exchange').operator()", noremap = true },
            { 'sxx', CMD "lua require('substitute.exchange').line()", noremap = true },
            { 'X', CMD "lua require('substitute.exchange').visual()", 'x', noremap = true },
            { 'sxc', CMD "lua require('substitute.exchange').cancel()", noremap = true },
        },
        config = function()
            require('substitute').setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end,
    },

    { -- A neovim lua plugin to help easily manage multiple terminal windows
        'akinsho/toggleterm.nvim',
        keys = {
            { '<F12>', CMD 'ToggleTerm', silent = true, desc = 'Floaterm: toggle' },
            { '<F12>', ([[<C-\><C-n>]] .. CMD 'ToggleTerm'), 't', silent = true, desc = 'Terminal: toggle' },
        },
        cmd = { 'ToggleTerm' },
        config = function()
            require('toggleterm').setup {}
        end,
    },

    { -- Quickstart configs for Nvim LSP
        'neovim/nvim-lspconfig',
        name = 'lspconfig',
        config = function()
            require('settings.lspconfig').setup()
        end,
    },
    -- LSP modules
    {
        'ray-x/lsp_signature.nvim',
        lazy = true,
        config = function()
            require('lsp_signature').setup {
                toggle_key = '<C-S>',
                floating_window = false,
            }
        end,
    },
    {
        'SmiteshP/nvim-navic',
        lazy = true,
    },

    { -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
        'jose-elias-alvarez/null-ls.nvim',
        event = 'VeryLazy',
        config = function()
            require('settings.null-ls').setup()
        end,
        dependencies = { 'nvim-lua/plenary.nvim' },
    },

    { -- A completion plugin for neovim coded in Lua.
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            {
                'L3MON4D3/LuaSnip',
                config = function()
                    require('settings.luasnip').setup()
                end,
            }, -- snippet engine
            'hrsh7th/cmp-nvim-lsp', -- language server protocol
            'hrsh7th/cmp-buffer', -- completion from current buffer
            'saadparwaiz1/cmp_luasnip', -- completion from snippets
            'onsails/lspkind-nvim', -- print completion source in menu
            'hrsh7th/cmp-path', -- completion for filesystem
        },
        priority = 19,
        config = function()
            require('settings.cmp').setup()
        end,
    },

    { -- A file explorer tree for neovim written in lua
        'nvim-tree/nvim-tree.lua',
        dependencies = {
            'kyazdani42/nvim-web-devicons',
        },
        keys = {
            {
                [[<C-\>]],
                function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    local filepath = vim.fn.fnamemodify(bufname, ':p')

                    require('nvim-tree.api').tree.open()
                    require('nvim-tree.api').tree.find_file(filepath)
                end,
                desc = 'Nvimtree: select current file',
            },
            {
                [[<leader><leader>]],
                function()
                    require('nvim-tree.api').tree.toggle(false, true)
                end,
                desc = 'Nvimtree: toggle',
            },
        },
        config = function()
            require('nvim-tree').setup { sync_root_with_cwd = true, respect_buf_cwd = true }
        end,
        version = 'nightly', -- optional, updated every week. (see issue #1193)
    },

    { -- fugitive.vim: A Git wrapper so awesome, it should be illegal
        'tpope/vim-fugitive',
        cmd = { 'G', 'Git' },
    },
    { -- magit for neovim
        'TimUntersberger/neogit',
        cmd = { 'Neogit' },
        dependencies = 'nvim-lua/plenary.nvim',
    },

    { -- Add/change/delete surrounding delimiter pairs with ease. Written with heart in Lua.
        'kylechui/nvim-surround',
        event = 'InsertEnter',
        version = '*',
        config = function()
            require('nvim-surround').setup {
                -- Configuration here, or leave empty to use defaults
            }
        end,
    },

    { -- Git integration for buffers
        'lewis6991/gitsigns.nvim',
        event = 'VeryLazy',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local gitsigns = require 'gitsigns'
            gitsigns.setup {
                current_line_blame = true,

                on_attach = function()
                    local gs = package.loaded.gitsigns

                    -- Navigation
                    if not vim.api.nvim_win_get_option(0, 'diff') then
                        vim.keymap.set('n', ']c', gs.next_hunk, { desc = 'Git: Goto next hunk' })
                        vim.keymap.set('n', '[c', gs.prev_hunk, { desc = 'Git: Goto prev hunk' })
                    end

                    -- Actions
                    vim.keymap.set({ 'n', 'v' }, '<leader>hs', gs.stage_hunk, { desc = 'Git: Stage hunk' })
                    vim.keymap.set({ 'n', 'v' }, '<leader>hr', gs.reset_hunk, { desc = 'Git: Reset hunk' })
                    vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { desc = 'Git: Stage buffer' })
                    vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Git: Undo stage hunk' })
                    vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { desc = 'Git: Reset buffer' })
                    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { desc = 'Git: Preview hunk' })
                    vim.keymap.set('n', '<leader>hb', function()
                        gs.blame_line { full = true }
                    end, { desc = 'Git: Blame line' })
                    vim.keymap.set('n', '<leader>hd', gs.diffthis, { desc = 'Git: Diff this file' })
                    vim.keymap.set('n', '<leader>hD', function()
                        gs.diffthis '~'
                    end, { desc = 'Git: Run diff this' })

                    -- Text object
                    vim.keymap.set({ 'o', 'x' }, 'ih', CMD '<C-U>Gitsigns select_hunk', { desc = 'Git: Select hunk' })
                end,
            }

            require('scrollbar.handlers.gitsigns').setup()
        end,
    },

    { -- Find, Filter, Preview, Pick. All lua, all the time.
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/popup.nvim',
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-ui-select.nvim',
            'nvim-telescope/telescope-project.nvim',
            'debugloop/telescope-undo.nvim',
        },
        cmd = 'Telescope',
        init = function()
            require('settings.telescope').setup()
        end,
        config = function()
            require('settings.telescope').config()
        end,
    },

    { -- Find the enemy and replace them with dark power.
        'windwp/nvim-spectre',
        keys = {
            {
                '<leader>/',
                CMD 'lua require("spectre").open()',
                desc = 'Spectre: Open search panel',
            },
            {
                '<leader>*',
                CMD 'lua require("spectre").open_visual { select_word = true }',
                desc = 'Spectre: Search word under cursor',
            },
        },
        config = function()
            require('spectre').setup {
                mapping = {
                    ['open_in_vsplit'] = {
                        map = '<c-v>',
                        cmd = CMD 'lua require("settings.spectre").vsplit()',
                        desc = 'open in vertical split',
                    },
                    ['open_in_split'] = {
                        map = '<c-s>',
                        cmd = CMD 'lua require("settings.spectre").split()',
                        desc = 'open in horizontal split',
                    },
                    ['open_in_tab'] = {
                        map = '<c-t>',
                        cmd = CMD 'lua require("settings.spectre").tabsplit()',
                        desc = 'open in new tab',
                    },
                },
            }
        end,
        dependencies = {
            'kyazdani42/nvim-web-devicons',
            'nvim-lua/popup.nvim',
            'nvim-lua/plenary.nvim',
        },
    },

    { -- Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more
        'numToStr/Comment.nvim',
        event = 'InsertEnter',
        config = function()
            require('Comment').setup()
        end,
    },

    { -- A tree like view for symbols in Neovim using the Language Server Protocol. Supports all your favourite languages.
        'simrat39/symbols-outline.nvim',
        cmd = { 'SymbolsOutline' },
        keys = {
            { '<F5>', CMD 'SymbolsOutline', desc = 'SymbolsOutline: Open symbols outline' },
        },
    },

    { -- Nvim Treesitter configurations and abstraction layer
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = 'VeryLazy',
        config = function()
            require('nvim-treesitter').setup()
            require('settings.treesitter').config()
            vim.cmd 'TSEnable highlight'
        end,
        dependencies = {
            { 'p00f/nvim-ts-rainbow' },
            'nvim-treesitter/nvim-treesitter-textobjects',
            {
                'mfussenegger/nvim-ts-hint-textobject',
                keys = {
                    {
                        'm',
                        '<C-U>:lua require("tsht").nodes()<cr>',
                        'o',
                        silent = true,
                        desc = 'Treesitter: Show treesitter select hints',
                    },
                    {
                        'm',
                        CMD 'lua require("tsht").nodes()',
                        'v',
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

    { -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
        'sindrets/diffview.nvim',
        dependencies = 'kyazdani42/nvim-web-devicons',
        cmd = { 'DiffviewOpen' },
    },

    { -- tmux integration for nvim features pane movement and resizing from within nvim.
        'aserowy/tmux.nvim',
        keys = {
            { '<c-h>', CMD 'lua require("tmux").move_left()', desc = 'Left movement' },
            { '<c-l>', CMD 'lua require("tmux").move_right()', desc = 'Right movement' },
            { '<a-h>', CMD 'lua require("tmux").move_left()', desc = 'Left movement' },
            { '<a-j>', CMD 'lua require("tmux").move_bottom()', desc = 'Bottom movement' },
            { '<a-k>', CMD 'lua require("tmux").move_top()', desc = 'Top movement' },
            { '<a-l>', CMD 'lua require("tmux").move_right()', desc = 'Right movement' },
        },
        config = function()
            require('tmux').setup {
                -- overwrite default configuration
                -- here, e.g. to enable default bindings
                copy_sync = {
                    -- enables copy sync and overwrites all register actions to
                    -- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
                    enable = false,
                },
            }
        end,
    },

    { -- kconfig runtime files for Vim
        'chrisbra/vim-kconfig',
        ft = 'kconfig',
    },

    { -- eunuch.vim: Helpers for UNIX
        'tpope/vim-eunuch',
        cmd = {
            'Delete',
            'Unlink',
            'Move',
            'Rename',
            'Chmod',
            'Mkdir',
            'SudoWrite',
            'SudoEdit',
        },
    },

    { -- Vim configuration files for Nix http://nixos.org/nix
        'LnL7/vim-nix',
        ft = 'nix',
    },

    { -- A plugin to visualise and resolve merge conflicts in neovim
        'akinsho/git-conflict.nvim',
        version = '*',
        cond = function()
            return vim.opt.diff:get()
        end,
        config = function()
            require('git-conflict').setup {
                default_mappings = true,
                default_commands = true,
                disable_diagnostics = false,
                highlights = { -- They must have background color, otherwise the default color will be used
                    incoming = 'Visual',
                    current = 'Visual',
                    ancestor = 'Visual',
                },
            }

            local augroup = vim.api.nvim_create_augroup('GitConflictAugroup', { clear = true })
            vim.api.nvim_create_autocmd('User', {
                group = augroup,
                pattern = 'GitConflictResolved',
                callback = function()
                    local CURRENT_HL = 'GitConflictCurrent'
                    local INCOMING_HL = 'GitConflictIncoming'
                    local ANCESTOR_HL = 'GitConflictAncestor'
                    local CURRENT_LABEL_HL = 'GitConflictCurrentLabel'
                    local INCOMING_LABEL_HL = 'GitConflictIncomingLabel'
                    local ANCESTOR_LABEL_HL = 'GitConflictAncestorLabel'
                    local visual_hl = vim.api.nvim_get_hl_by_name('Visual', true)

                    vim.api.nvim_set_hl(0, CURRENT_HL, { background = visual_hl.background, bold = true })
                    vim.api.nvim_set_hl(0, INCOMING_HL, { background = visual_hl.background, bold = true })
                    vim.api.nvim_set_hl(0, ANCESTOR_HL, { background = visual_hl.background, bold = true })
                    vim.api.nvim_set_hl(0, CURRENT_LABEL_HL, { background = visual_hl.background })
                    vim.api.nvim_set_hl(0, INCOMING_LABEL_HL, { background = visual_hl.background })
                    vim.api.nvim_set_hl(0, ANCESTOR_LABEL_HL, { background = visual_hl.background })
                end,
            })
        end,
    },

    { -- Vim syntax for TOML
        'cespare/vim-toml',
        ft = 'toml',
    },

    { -- Neovim motions on speed!
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
    },

    { -- Interactive real time neovim scratchpad for embedded lua engine - type and watch!
        'rafcamlet/nvim-luapad',
        cmd = { 'Luapad' },
    },

    { -- Quick change harpooned buffers
        'ThePrimeagen/harpoon',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim' },
        keys = {
            {
                '<Leader>`',
                function()
                    require('harpoon.ui').toggle_quick_menu()
                end,
                desc = 'Harpoon: show menu',
            },
            {
                '<Leader>h',
                function()
                    require('harpoon.mark').add_file()
                end,
                desc = 'Harpoon: toogle mark',
            },
            {
                '<Leader>1',
                function()
                    require('harpoon.ui').nav_file(1)
                end,
                desc = 'Harpoon: select 1 mark',
            },
            {
                '<Leader>2',
                function()
                    require('harpoon.ui').nav_file(2)
                end,
                desc = 'Harpoon: select 2 mark',
            },
            {
                '<Leader>3',
                function()
                    require('harpoon.ui').nav_file(3)
                end,
                desc = 'Harpoon: select 3 mark',
            },
            {
                '<Leader>4',
                function()
                    require('harpoon.ui').nav_file(4)
                end,
                desc = 'Harpoon: select 4 mark',
            },
            {
                '<Leader>5',
                function()
                    require('harpoon.ui').nav_file(5)
                end,
                desc = 'Harpoon: select 5 mark',
            },
            {
                '<Leader>6',
                function()
                    require('harpoon.ui').nav_file(6)
                end,
                desc = 'Harpoon: select 6 mark',
            },
        },
    },

    { -- Vim plugin that defines a new text object representing lines of code at the same indent level. Useful for python/vim scripts, etc.
        'michaeljsmith/vim-indent-object',
    },

    { -- Tools for better development in rust using neovim's builtin lsp
        'simrat39/rust-tools.nvim',
        ft = 'rust',
        config = function()
            require('settings.rust-tools').setup()
        end,
    },
    { -- A neovim plugin that helps managing crates.io dependencies
        'saecki/crates.nvim',
        ft = 'rust',
        event = { 'BufRead Cargo.toml' },
        dependencies = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            require('crates').setup()
        end,
    },

    { -- A better annotation generator. Supports multiple languages and annotation conventions.
        'danymat/neogen',
        cmd = 'Neogen',
        config = function()
            require('neogen').setup { enabled = true }
        end,
        dependencies = 'nvim-treesitter/nvim-treesitter',
    },

    { -- Foldtext customization in Neovim
        'anuvyklack/pretty-fold.nvim',
        event = 'VeryLazy',
        config = function()
            require('pretty-fold').setup {}
            require('fold-preview').setup()
        end,
        dependencies = { 'anuvyklack/nvim-keymap-amend', 'anuvyklack/fold-preview.nvim' },
    },

    { -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing.
        'folke/trouble.nvim',
        dependencies = 'kyazdani42/nvim-web-devicons',
        cmd = { 'Trouble', 'TroubleToggle' },
        config = function()
            require('trouble').setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end,
    },

    { -- Highlight, list and search todo comments in your projects
        'folke/todo-comments.nvim',
        event = 'VeryLazy',
        dependencies = 'nvim-lua/plenary.nvim',
        config = function()
            require('todo-comments').setup {
                highlight = {
                    before = '', -- "fg" or "bg" or empty
                    keyword = 'bg', -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
                    after = 'fg', -- "fg" or "bg" or empty
                    pattern = [[.*<(KEYWORDS)(\([^\)]*\))?:]],
                    comments_only = true, -- uses treesitter to match keywords in comments only
                    max_line_len = 400, -- ignore lines longer than this
                    exclude = {}, -- list of file types to exclude highlighting
                },
                search = {
                    command = 'rg',
                    args = {
                        '--color=never',
                        '--no-heading',
                        '--with-filename',
                        '--line-number',
                        '--column',
                    },
                    pattern = [[\b(KEYWORDS)(\([^\)]*\))?:]],
                },
            }
        end,
    },

    { -- Vim and Neovim plugin to reveal the commit messages under the cursor
        'rhysd/git-messenger.vim',
        cmd = { 'GitMessenger' },
        keys = { { '<leader>gm', '<Plug>(git-messenger)', desc = 'GitMessenger: show git commit' } },
    },

    { --  Peek lines just when you intend
        'nacro90/numb.nvim',
        event = { 'CmdlineChanged', 'CmdlineLeave' },
        config = function()
            require('numb').setup()
        end,
    },

    { -- Debug Adapter Protocol client implementation for Neovim
        'mfussenegger/nvim-dap',
        keys = {
            {
                '<leader>db',
                function()
                    require('dap').toggle_breakpoint()
                end,
                { desc = 'DAP: toggle breakpoint in the current line' },
            },
            {
                '<leader>dB',
                function()
                    require('dap').toggle_breakpoint(vim.fn.input 'Breakpoint condition: ')
                end,
                { desc = 'DAP: toggle conditional breakpoint in the current line' },
            },
            {
                '<leader>dc',
                function()
                    require('dap').continue()
                end,
                { desc = 'DAP: continue' },
            },
            {
                '<leader>ds',
                function()
                    require('dap').step_over()
                end,
                { desc = 'DAP: step over' },
            },
            {
                '<leader>di',
                function()
                    require('dap').step_into()
                end,
                { desc = 'DAP: step into' },
            },
            {
                '<leader>do',
                function()
                    require('dap').step_out()
                end,
                { desc = 'DAP: step out' },
            },
            {
                '<leader>dr',
                function()
                    require('dap').repl.open()
                end,
                { desc = 'DAP: open repl' },
            },
            {
                '<leader>dh',
                function()
                    require('dap.ui.variables').hover()
                end,
                { desc = 'DAP: display hover information about the current variable' },
            },
        },
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
            'nvim-telescope/telescope-dap.nvim',
        },
        config = function()
            require('telescope').load_extension 'dap'
            require('settings.dap').config()
        end,
    },

    { -- A better user experience for viewing and interacting with Vim marks.
        'chentoast/marks.nvim',
        event = 'VeryLazy',
        config = function()
            require('marks').setup { default_mappings = true }
        end,
    },

    { -- VIM Table Mode for instant table creation.
        'dhruvasagar/vim-table-mode',
        keys = {
            { '<leader>tm', CMD 'TableModeToggle', desc = 'TableMode: toggle' },
        },
        cmd = { 'TableModeToggle' },
    },

    { -- Better quickfix window in Neovim, polish old quickfix window.
        'kevinhwang91/nvim-bqf',
        ft = 'qf',
    },

    { -- An all in one plugin for converting text case in Neovim
        'johmsalas/text-case.nvim',
        keys = {
            { 'ga.', CMD 'TextCaseOpenTelescope', 'v', desc = 'text-case: convert case' },
            { 'ga.', CMD 'TextCaseOpenTelescope', desc = 'text-case: convert case' },
        },
        init = function()
            TODO_OR_DIE.after_date(2023, 01, 14)
            require('settings.textcase').setup()
        end,
        config = function()
            require('settings.textcase').config()
        end,
    },

    { -- A minimal plugin for NeoVim for aligning lines
        'Vonr/align.nvim',
        keys = {
            {
                '<leader>aa',
                function()
                    require('align').align_to_char(1, true)
                end,
                'x',
                desc = 'Align: aligns to 1 character, looking left',
                silent = true,
            },
            {
                '<leader>as',
                function()
                    require('align').align_to_char(2, true, true)
                end,
                'x',
                desc = 'Align: aligns to 2 characters, looking left and with previews',
                silent = true,
            },
            {
                'aw',
                function()
                    require('align').align_to_string(false, true, true)
                end,
                'x',
                desc = 'Align: aligns to a string, looking left and with previews',
                silent = true,
            },
            {
                'ar',
                function()
                    require('align').align_to_string(true, true, true)
                end,
                'x',
                desc = 'Align: aligns to a Lua pattern, looking left and with previews',
                silent = true,
            },
            {
                'gaw',
                function()
                    local a = require 'align'
                    a.operator(a.align_to_string, { is_pattern = false, reverse = true, preview = true })
                end,
                desc = 'Align: align a paragraph to a string, looking left and with previews',
                silent = true,
            },
            {
                'gaa',
                function()
                    local a = require 'align'
                    a.operator(a.align_to_char, { reverse = true })
                end,
                desc = 'Align: aling a paragraph to 1 character, looking left',
                silent = true,
            },
        },
        config = function()
            -- Remove if I do not use it
            TODO_OR_DIE.after_date(2023, 01, 14)
        end,
    },

    { -- Orgmode clone written in Lua for Neovim 0.7+.
        'nvim-orgmode/orgmode',
        ft = 'org',
        init = function()
            vim.keymap.set('n', '<Leader>oa', function()
                require('orgmode').action 'agenda.prompt'
            end, { desc = 'Orgmode: open agenda view' })
            vim.keymap.set('n', '<Leader>oc', function()
                require('orgmode').action 'capture.prompt'
            end, { desc = 'Orgmode: open capture view' })
        end,
        config = function()
            require('orgmode').setup {
                org_agenda_files = { '~/Documents/orgs/**/*' },
                org_default_notes_file = '~/Documents/orgs/refile.org',
            }
            require('orgmode').setup_ts_grammar()
            require('org-bullets').setup {}
        end,
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'akinsho/org-bullets.nvim' },
    },

    { -- A small Neovim plugin to highlight too long lines
        'lcheylus/overlength.nvim',
        config = function()
            require('overlength').setup {
                disable_ft = {
                    'NvimTree',
                    'Telescope',
                    'WhichKey',
                    'diff',
                    'gitcommit',
                    'help',
                    'json',
                    'man',
                    'packer',
                    'qf',
                },
            }
        end,
    },

    {
        'stevearc/overseer.nvim',
        keys = {
            { '<leader>ot', CMD 'OverseerToggle', desc = 'Overseer: Toggle' },
            { '<leader>or', CMD 'OverseerRun', desc = 'Overseer: Run' },
            { '<leader>ob', CMD 'OverseerBuild', desc = 'Overseer: Build' },
        },
        cmd = { 'OverseerRun', 'OverseerBuild', 'OverseerToggle' },
        config = function()
            require('settings.overseer').config()
        end,
    },

    {
        'ckolkey/ts-node-action',
        keys = {
            {
                '-',
                function()
                    require('ts-node-action').node_action()
                end,
                desc = 'Trigger Node Action',
            },
        },
        dependencies = { 'nvim-treesitter' },
        config = function() -- Optional
            require('ts-node-action').setup {}
        end,
    },
}
