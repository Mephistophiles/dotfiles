-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

local packer = require 'packer'
local use = packer.use

return packer.startup {
    function()
        -- Packer can manage itself
        use 'wbthomason/packer.nvim'
        -- Speedup loading
        use 'lewis6991/impatient.nvim'

        -- filedetect drop-in-placement
        use {
            'nathom/filetype.nvim',
            setup = function()
                vim.g.did_load_filetypes = 1
            end,
            config = function()
                require('settings.filetypes').config()
            end,
        }

        -- extended repeat ('.') for another plugins
        use 'tpope/vim-repeat'

        use {
            'RRethy/vim-illuminate',
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
                }
            end,
        }

        use {
            'luukvbaal/stabilize.nvim',
            config = function()
                require('stabilize').setup()
            end,
        }

        use {
            'cshuaimin/ssr.nvim',
            module = 'ssr',
            setup = function()
                vim.keymap.set({ 'n', 'x' }, '<leader>sr', function()
                    require('ssr').open()
                end)
            end,
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
        }

        use {
            'declancm/windex.nvim',
            keys = { { 'n', '<leader>z', 'Windex: Toggle maximizing the current window' } },
            config = function()
                require('windex').setup {
                    default_keymaps = false,
                }
                vim.keymap.set(
                    'n',
                    '<Leader>z',
                    "<Cmd>lua require('windex').toggle_nvim_maximize()<CR>",
                    { desc = 'Windex: Toggle maximizing the current window' }
                )
            end,
        }

        -- mkdir
        use {
            'jghauser/mkdir.nvim',
        }

        use {
            'lcheylus/overlength.nvim',
            config = function()
                require('overlength').setup {
                    disable_ft = { 'diff', 'gitcommit', 'json' },
                }
            end,
        }

        use {
            'goolord/alpha-nvim',
            requires = { 'kyazdani42/nvim-web-devicons' },
            config = function()
                require('alpha').setup(require('alpha.themes.startify').config)
            end,
        }

        use {
            'gbprod/substitute.nvim',
            config = function()
                require('substitute').setup {
                    -- your configuration comes here
                    -- or leave it empty to use the default settings
                    -- refer to the configuration section below
                }
                vim.keymap.set('n', 's', "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
                vim.keymap.set('n', 'ss', "<cmd>lua require('substitute').line()<cr>", { noremap = true })
                vim.keymap.set('n', 'S', "<cmd>lua require('substitute').eol()<cr>", { noremap = true })
                vim.keymap.set('x', 's', "<cmd>lua require('substitute').visual()<cr>", { noremap = true })
                vim.keymap.set(
                    'n',
                    '<leader>s',
                    "<cmd>lua require('substitute.range').operator()<cr>",
                    { noremap = true }
                )
                vim.keymap.set(
                    'x',
                    '<leader>s',
                    "<cmd>lua require('substitute.range').visual()<cr>",
                    { noremap = true }
                )
                vim.keymap.set('n', '<leader>ss', "<cmd>lua require('substitute.range').word()<cr>", { noremap = true })
                vim.keymap.set('n', 'sx', "<cmd>lua require('substitute.exchange').operator()<cr>", { noremap = true })
                vim.keymap.set('n', 'sxx', "<cmd>lua require('substitute.exchange').line()<cr>", { noremap = true })
                vim.keymap.set('x', 'X', "<cmd>lua require('substitute.exchange').visual()<cr>", { noremap = true })
                vim.keymap.set('n', 'sxc', "<cmd>lua require('substitute.exchange').cancel()<cr>", { noremap = true })
            end,
        }

        use {
            'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
            module = 'lsp_lines',
            setup = function()
                vim.keymap.set('n', '<leader>ll', require('lsp_lines').toggle, { desc = 'Toggle lsp_lines' })
                vim.diagnostic.config { virtual_lines = false }
            end,
            config = function()
                require('lsp_lines').setup()
            end,
        }

        use {
            'akinsho/toggleterm.nvim',
            setup = function()
                vim.keymap.set('n', '<F12>', [[:ToggleTerm<CR>]], { silent = true, desc = 'Floaterm: toggle' })
                vim.keymap.set(
                    't',
                    '<F12>',
                    [[<C-\><C-n>:ToggleTerm<CR>]],
                    { silent = true, desc = 'Terminal: toggle' }
                )
            end,
            cmd = { 'ToggleTerm' },
            config = function()
                require('toggleterm').setup {
                    shell = 'fish',
                }
            end,
        }

        use {
            'stevearc/overseer.nvim',
            cmd = { 'OverseerRun', 'OverseerBuild', 'OverseerToggle' },
            setup = function()
                require('settings.overseer').setup()
            end,
            config = function()
                require('settings.overseer').config()
            end,
        }

        use {
            'anuvyklack/hydra.nvim',
            setup = function()
                require('settings.hydra').setup()
            end,
            config = function()
                require('settings.hydra').config()
            end,
            requires = { 'mrjones2014/smart-splits.nvim' },
        }

        use {
            'gpanders/editorconfig.nvim',
        }

        use {
            'neovim/nvim-lspconfig',
            requires = {
                {
                    'ray-x/lsp_signature.nvim',
                    config = function()
                        require('lsp_signature').setup {
                            toggle_key = '<C-S>',
                            floating_window = false,
                        }
                    end,
                },
            },
        }

        use {
            'jose-elias-alvarez/null-ls.nvim',
            config = function()
                require('settings.null-ls').setup()
            end,
            requires = { 'nvim-lua/plenary.nvim' },
        }

        use {
            'L3MON4D3/LuaSnip',
            config = function()
                require('settings.luasnip').setup()
            end,
        } -- snippet engine
        use 'hrsh7th/nvim-cmp'
        use 'hrsh7th/cmp-nvim-lsp' -- language server protocol
        use 'hrsh7th/cmp-buffer' -- completion from current buffer
        use 'saadparwaiz1/cmp_luasnip' -- completion from snippets
        use 'onsails/lspkind-nvim' -- print completion source in menu
        use 'hrsh7th/cmp-path' -- completion for filesystem
        -- use { 'tzachar/cmp-tabnine', run = './install.sh' } -- tabnine

        use 'wsdjeg/vim-fetch'

        use {
            'tjdevries/express_line.nvim',
            requires = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' },
            setup = function()
                require('settings.express_line').setup()
            end,
            config = function()
                require('settings.express_line').config()
            end,
        }
        use {
            'folke/tokyonight.nvim',
            setup = function()
                vim.opt.background = 'dark'
                vim.opt.termguicolors = true
            end,
            config = function()
                vim.cmd 'colorscheme tokyonight'
            end,
        }

        use {
            'ahmedkhalf/project.nvim',
            config = function()
                require('project_nvim').setup {
                    detection_methods = { 'pattern' },
                    patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn' },
                }
            end,
        }

        use {
            'nvim-neo-tree/neo-tree.nvim',
            -- cmd = { 'Neotree' },
            requires = {
                'nvim-lua/plenary.nvim',
                'kyazdani42/nvim-web-devicons', -- not strictly required, but recommended
                'MunifTanjim/nui.nvim',
            },
            setup = function()
                require('settings.neo-tree').setup()
            end,
            config = function()
                require('settings.neo-tree').config()
            end,
        }

        use { 'tpope/vim-fugitive', cmd = { 'G', 'Git' }, opt = true }
        use { 'TimUntersberger/neogit', cmd = { 'Neogit' }, requires = 'nvim-lua/plenary.nvim' }

        use {
            'kylechui/nvim-surround',
            tag = '*',
            config = function()
                require('nvim-surround').setup {
                    -- Configuration here, or leave empty to use defaults
                }
            end,
        }

        use {
            'lewis6991/gitsigns.nvim',
            event = { 'CursorHold', 'InsertEnter' },
            requires = { 'nvim-lua/plenary.nvim' },
            config = function()
                require('gitsigns').setup {
                    current_line_blame = true,

                    on_attach = function()
                        local gs = package.loaded.gitsigns

                        -- Navigation
                        vim.keymap.set(
                            'n',
                            ']c',
                            [[&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>']],
                            { expr = true, desc = 'Git: Goto next hunk' }
                        )
                        vim.keymap.set(
                            'n',
                            '[c',
                            [[&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>']],
                            { expr = true, desc = 'Git: Goto prev hunk' }
                        )

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
                        vim.keymap.set(
                            { 'o', 'x' },
                            'ih',
                            ':<C-U>Gitsigns select_hunk<CR>',
                            { desc = 'Git: Select hunk' }
                        )
                    end,
                }
            end,
        }

        use {
            'nvim-telescope/telescope.nvim',
            requires = {
                { 'nvim-lua/popup.nvim', module = 'popup' },
                'nvim-lua/plenary.nvim',
                'nvim-telescope/telescope-ui-select.nvim',
                'nvim-telescope/telescope-project.nvim',
            },
            setup = function()
                require('settings.telescope').setup()
            end,
            config = function()
                require('settings.telescope').config()
            end,
        }

        use {
            'windwp/nvim-spectre',
            opt = true,
            module = 'spectre',
            setup = function()
                vim.keymap.set(
                    'n',
                    '<leader>/',
                    ':lua require("spectre").open()<cr>',
                    { desc = 'Spectre: Open search panel' }
                )
                vim.keymap.set(
                    'n',
                    '<leader>*',
                    ':lua require("spectre").open_visual { select_word = true }<cr>',
                    { desc = 'Spectre: Search word under cursor' }
                )
            end,
            config = function()
                require('spectre').setup {
                    mapping = {
                        ['open_in_vsplit'] = {
                            map = '<c-v>',
                            cmd = '<cmd>lua require("settings.spectre").vsplit()<CR>',
                            desc = 'open in vertical split',
                        },
                        ['open_in_split'] = {
                            map = '<c-s>',
                            cmd = '<cmd>lua require("settings.spectre").split()<CR>',
                            desc = 'open in horizontal split',
                        },
                        ['open_in_tab'] = {
                            map = '<c-t>',
                            cmd = '<cmd>lua require("settings.spectre").tabsplit()<CR>',
                            desc = 'open in new tab',
                        },
                    },
                }
            end,
            requires = {
                'kyazdani42/nvim-web-devicons',
                { 'nvim-lua/popup.nvim', module = 'popup' },
                'nvim-lua/plenary.nvim',
            },
        }

        use {
            'numToStr/Comment.nvim',
            config = function()
                require('Comment').setup()
            end,
        }

        use {
            'simrat39/symbols-outline.nvim',
            cmd = { 'SymbolsOutline' },
            setup = function()
                vim.keymap.set(
                    'n',
                    '<F5>',
                    '<cmd>SymbolsOutline<cr>',
                    { desc = 'SymbolsOutline: Open symbols outline' }
                )
            end,
        }

        use {
            'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate',
            config = function()
                require('settings.treesitter').config()
            end,
            requires = {
                { 'p00f/nvim-ts-rainbow' },
                {
                    'nvim-treesitter/playground',
                    cmd = { 'TSPlaygroundToggle' },
                },
                'nvim-treesitter/nvim-treesitter-textobjects',
                {
                    'mfussenegger/nvim-ts-hint-textobject',
                    setup = function()
                        vim.keymap.set(
                            'o',
                            'm',
                            '<C-U>:lua require("tsht").nodes()<cr>',
                            { silent = true, desc = 'Treesitter: Show treesitter select hints' }
                        )
                        vim.keymap.set(
                            'v',
                            'm',
                            ':lua require("tsht").nodes()<cr>',
                            { silent = true, desc = 'Treesitter: Show treesitter select hints' }
                        )
                    end,
                    opt = true,
                    module = 'tsht',
                },
                {
                    'nvim-treesitter/nvim-treesitter-refactor',
                },
                {
                    'lewis6991/nvim-treesitter-context',
                },
            },
        }

        use {
            'NMAC427/guess-indent.nvim',
            config = function()
                require('guess-indent').setup {}
            end,
        }

        use {
            'sindrets/diffview.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
            cmd = { 'DiffviewOpen' },
            opt = true,
        }

        use {
            'mbbill/undotree',
            cmd = 'UndotreeToggle',
            setup = function()
                vim.keymap.set('n', '<F3>', '<cmd>UndotreeToggle<CR>', { desc = 'Undotree: toggle' })
            end,
            opt = true,
        }

        use {
            'monaqa/dial.nvim',
            cmd = 'Switch',
            keys = {
                { 'n', '<C-a>', 'Increment' },
                { 'n', '<C-x>', 'Decrement' },
                { 'v', '<C-a>', 'Increment' },
                { 'v', '<C-x>', 'Decrement' },
                { 'v', 'g<C-a>', 'Increment' },
                { 'v', 'g<C-x>', 'Decrement' },
            },
            setup = function()
                require('settings.dial').setup()
            end,

            config = function()
                require('settings.dial').config()
            end,
        }

        use {
            'aserowy/tmux.nvim',
            keys = {
                { 'n', '<c-h>', 'Left movement' },
                { 'n', '<c-l>', 'Right movement' },
                { 'n', '<a-h>', 'Left movement' },
                { 'n', '<a-j>', 'Bottom movement' },
                { 'n', '<a-k>', 'Top movement' },
                { 'n', '<a-l>', 'Right movement' },
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

                vim.keymap.set('n', '<c-h>', '<cmd>lua require("tmux").move_left()<cr>', { desc = 'Left movement' })
                vim.keymap.set('n', '<c-l>', '<cmd>lua require("tmux").move_right()<cr>', { desc = 'Right movement' })
                vim.keymap.set('n', '<a-h>', '<cmd>lua require("tmux").move_left()<cr>', { desc = 'Left movement' })
                vim.keymap.set('n', '<a-j>', '<cmd>lua require("tmux").move_bottom()<cr>', { desc = 'Bottom movement' })
                vim.keymap.set('n', '<a-k>', '<cmd>lua require("tmux").move_top()<cr>', { desc = 'Top movement' })
                vim.keymap.set('n', '<a-l>', '<cmd>lua require("tmux").move_right()<cr>', { desc = 'Right movement' })
            end,
        }

        use {
            'chrisbra/vim-kconfig',
            ft = 'kconfig',
        }

        use {
            'tpope/vim-eunuch',
            opt = true,
            cmd = {
                'Delete',
                'Unlink',
                'Move',
                'Rename',
                'Chmod',
                'Mkdir',
                'Cfind',
                'Clocate',
                'Lfind/',
                'Wall',
                'SudoWrite',
                'SudoEdit',
            },
        }

        use { 'LnL7/vim-nix', opt = true, ft = 'nix' }

        use {
            'akinsho/git-conflict.nvim',
            tag = '*',
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
        }

        use { 'cespare/vim-toml', ft = 'toml' }

        use {
            'phaazon/hop.nvim',
            opt = true,
            module = 'hop',
            setup = function()
                local direction = require('hop.hint').HintDirection
                vim.keymap.set('n', '<Leader>w', function()
                    require('hop').hint_words { direction = direction.AFTER_CURSOR }
                end, {
                    desc = 'Hop: Annotate all words after cursor in the current window with key sequences.',
                })
                vim.keymap.set('n', '<Leader>b', function()
                    require('hop').hint_words { direction = direction.BEFORE_CURSOR }
                end, {
                    desc = 'Hop: Annotate all words before cursor in the current window with key sequences.',
                })
            end,
            config = function()
                require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }
            end,
        }

        use { 'rafcamlet/nvim-luapad', cmd = { 'Luapad' } }

        use { 'xiyaowong/nvim-cursorword' }

        use {
            'ThePrimeagen/harpoon',
            requires = { 'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim' },
            module = 'harpoon',
            setup = function()
                vim.keymap.set('n', '<Leader>`', function()
                    require('harpoon.ui').toggle_quick_menu()
                end, { desc = 'Harpoon: show menu' })
                vim.keymap.set('n', '<Leader>h', function()
                    require('harpoon.mark').add_file()
                end, { desc = 'Harpoon: toogle mark' })
                vim.keymap.set('n', '<Leader>1', function()
                    require('harpoon.ui').nav_file(1)
                end, { desc = 'Harpoon: select 1 mark' })
                vim.keymap.set('n', '<Leader>2', function()
                    require('harpoon.ui').nav_file(2)
                end, { desc = 'Harpoon: select 2 mark' })
                vim.keymap.set('n', '<Leader>3', function()
                    require('harpoon.ui').nav_file(3)
                end, { desc = 'Harpoon: select 3 mark' })
                vim.keymap.set('n', '<Leader>4', function()
                    require('harpoon.ui').nav_file(4)
                end, { desc = 'Harpoon: select 4 mark' })
                vim.keymap.set('n', '<Leader>5', function()
                    require('harpoon.ui').nav_file(5)
                end, { desc = 'Harpoon: select 5 mark' })
                vim.keymap.set('n', '<Leader>6', function()
                    require('harpoon.ui').nav_file(6)
                end, { desc = 'Harpoon: select 6 mark' })
            end,
        }

        use { 'teal-language/vim-teal', ft = 'teal' }
        use { 'andymass/vim-matchup' }
        use {
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
                        'Stacktrace in notifications was '
                            .. (vim.g.nvim_notify_stack_trace and 'enabled' or 'disabled'),
                        vim.log.levels.INFO
                    )
                end, { desc = 'Notifications: toggle stacktrace from warn and above' })
            end,
        }

        use { 'michaeljsmith/vim-indent-object' }

        use 'simrat39/rust-tools.nvim'
        use {
            'saecki/crates.nvim',
            ft = 'rust',
            event = { 'BufRead Cargo.toml' },
            requires = { { 'nvim-lua/plenary.nvim' } },
            config = function()
                require('crates').setup()
            end,
        }

        use {
            'danymat/neogen',
            cmd = 'Neogen',
            config = function()
                require('neogen').setup { enabled = true }
            end,
            requires = 'nvim-treesitter/nvim-treesitter',
        }

        use {
            'anuvyklack/pretty-fold.nvim',
            event = { 'CursorHold' },
            config = function()
                require('pretty-fold').setup {}
                require('fold-preview').setup()
            end,
            requires = { 'anuvyklack/nvim-keymap-amend', 'anuvyklack/fold-preview.nvim' },
        }

        use 'stevearc/dressing.nvim'

        use {
            'folke/trouble.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
            cmd = { 'Trouble', 'TroubleToggle' },
            config = function()
                require('trouble').setup {
                    -- your configuration comes here
                    -- or leave it empty to use the default settings
                    -- refer to the configuration section below
                }
            end,
        }

        use {
            'folke/todo-comments.nvim',
            requires = 'nvim-lua/plenary.nvim',
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
        }

        use {
            'rhysd/git-messenger.vim',
            cmd = { 'GitMessenger' },
            keys = { { '', '<leader>gm', 'GitMessenger: show git commit' } },
            setup = function()
                vim.keymap.set('n', '<leader>gm', '<Plug>(git-messenger)', { desc = 'GitMessager: show git commit' })
            end,
        }

        use {
            'j-hui/fidget.nvim',
            config = function()
                require('fidget').setup { text = { spinner = 'dots' }, align = { bottom = true } }
            end,
        }

        use {
            'nacro90/numb.nvim',
            config = function()
                require('numb').setup()
            end,
        }

        use {
            'mfussenegger/nvim-dap',
            requires = {
                'rcarriga/nvim-dap-ui',
                'theHamsta/nvim-dap-virtual-text',
                'nvim-telescope/telescope-dap.nvim',
            },
            keys = {
                { 'n', '<leader>db', 'DAP: toggle breakpoint in the current line' },
                { 'n', '<leader>dB', 'DAP: toggle conditional breakpoint in the current line' },
                { 'n', '<leader>dc', 'DAP: continue' },
                { 'n', '<leader>ds', 'DAP: step over' },
                { 'n', '<leader>di', 'DAP: step into' },
                { 'n', '<leader>do', 'DAP: step out' },
                { 'n', '<leader>dr', 'DAP: open repl' },
                { 'n', '<leader>dh', 'DAP: display hover information about the current variable' },
            },
            setup = function()
                require('settings.dap').setup()
            end,
            config = function()
                require('telescope').load_extension 'dap'
                require('settings.dap').config()
            end,
        }

        use {
            'chrisbra/NrrwRgn',
            cmd = { 'NR', 'NW', 'WR', 'NRV', 'NUD', 'NRP', 'NRM', 'NRS', 'NRN', 'NRL' },
            setup = function()
                vim.g.nrrw_rgn_nomap_nr = 1
                vim.g.nrrw_rgn_nomap_Nr = 1
            end,
        }

        use {
            'chentoast/marks.nvim',
            event = { 'CursorHold', 'InsertEnter' },
            config = function()
                require('marks').setup { default_mappings = true }
            end,
        }

        use { 'timcharper/textile.vim', ft = 'textile' }

        use {
            'klen/nvim-config-local',
            config = function()
                require('config-local').setup {
                    -- Default configuration (optional)
                    config_files = { '.vimrc.lua', '.vimrc', 'vimrc.ext.lua' }, -- Config file patterns to load (lua supported)
                    hashfile = vim.fn.stdpath 'data' .. '/config-local', -- Where the plugin keeps files data
                    autocommands_create = true, -- Create autocommands (VimEnter, DirectoryChanged)
                    commands_create = true, -- Create commands (ConfigSource, ConfigEdit, ConfigTrust, ConfigIgnore)
                    silent = true, -- Disable plugin messages (Config loaded/ignored)
                    lookup_parents = true, -- Lookup config files in parent directories
                }
            end,
        }

        use {
            'folke/zen-mode.nvim',
            cmd = { 'ZenMode' },
            config = function()
                require('zen-mode').setup {
                    plugins = {
                        gitsigns = { enabled = true },
                        tmux = { enabled = true },
                        kitty = {
                            enabled = true,
                            font = '+4', -- font size increment
                        },
                    },
                }
            end,
        }
        use {
            'folke/twilight.nvim',
            cmd = { 'Twilight', 'TwilightEnable' },
            config = function()
                require('twilight').setup {}
            end,
        }

        use {
            'dhruvasagar/vim-table-mode',
            setup = function()
                vim.keymap.set('n', '<leader>tm', ':TableModeToggle<cr>', { desc = 'TableMode: toggle' })
            end,
            cmd = { 'TableModeToggle' },
        }

        use {
            'folke/which-key.nvim',
            config = function()
                require('which-key').setup {
                    -- your configuration comes here
                    -- or leave it empty to use the default settings
                    -- refer to the configuration section below
                }
            end,
        }

        use {
            'lukas-reineke/indent-blankline.nvim',
            config = function()
                require('indent_blankline').setup {
                    space_char_blankline = ' ',
                    show_current_context = false,
                    show_current_context_start = false,
                }
            end,
        }

        use { 'kevinhwang91/nvim-bqf', ft = 'qf' }

        use {
            'johmsalas/text-case.nvim',
            setup = function()
                require('settings.textcase').setup()
            end,
            config = function()
                require('settings.textcase').config()
            end,
        }

        use {
            'Vonr/align.nvim',
            keys = {
                { 'x', '<leader>aa', 'Align: aligns to 1 character, looking left' },
                { 'x', '<leader>as', 'Align: aligns to 2 characters, looking left and with previews' },
                { 'x', 'aw', 'Align: aligns to a string, looking left and with previews' },
                { 'x', 'ar', 'Align: aligns to a Lua pattern, looking left and with previews' },
                { 'n', 'gaw', 'Align: align a paragraph to a string, looking left and with previews' },
                { 'n', 'gaa', 'Align: aling a paragraph to 1 character, looking left' },
            },
            config = function()
                local function o(desc)
                    return { noremap = true, silent = true, desc = desc }
                end

                vim.keymap.set('x', '<leader>aa', function()
                    require('align').align_to_char(1, true)
                end, o 'Align: aligns to 1 character, looking left')
                vim.keymap.set('x', '<leader>as', function()
                    require('align').align_to_char(2, true, true)
                end, o 'Align: aligns to 2 characters, looking left and with previews')
                vim.keymap.set('x', 'aw', function()
                    require('align').align_to_string(false, true, true)
                end, o 'Align: aligns to a string, looking left and with previews')

                vim.keymap.set('x', 'ar', function()
                    require('align').align_to_string(true, true, true)
                end, o 'Align: aligns to a Lua pattern, looking left and with previews')

                vim.keymap.set('n', 'gaw', function()
                    local a = require 'align'
                    a.operator(a.align_to_string, { is_pattern = false, reverse = true, preview = true })
                end, o 'Align: align a paragraph to a string, looking left and with previews')

                vim.keymap.set('n', 'gaa', function()
                    local a = require 'align'
                    a.operator(a.align_to_char, { reverse = true })
                end, o 'Align: aling a paragraph to 1 character, looking left')
            end,
        }

        use {
            'rcarriga/neotest',
            cmd = { 'Neotest', 'NeotestRun' },
            module = 'neotest',
            requires = {
                'nvim-lua/plenary.nvim',
                'rcarriga/neotest-plenary',
                'rouge8/neotest-rust',
                -- 'rcarriga/neotest-vim-test',
                'nvim-treesitter/nvim-treesitter',
            },
            setup = function()
                require('settings.neotest').setup()
            end,
            config = function()
                require('settings.neotest').config()
            end,
        }

        use {
            'nvim-neorg/neorg',
            ft = 'norg',
            after = 'nvim-treesitter',
            config = function()
                require('neorg').setup {
                    load = {
                        ['core.defaults'] = {},
                        ['core.norg.completion'] = { config = { engine = 'nvim-cmp' } },
                        ['core.norg.concealer'] = {},
                        ['core.norg.dirman'] = {
                            config = {
                                workspaces = {
                                    work = '~/notes/work',
                                    home = '~/notes/home',
                                },
                            },
                        },
                    },
                }
            end,
            requires = 'nvim-lua/plenary.nvim',
        }

        use {
            'vmchale/dhall-vim',
            ft = 'dhall',
        }
    end,
    config = {
        -- Move to lua dir so impatient.nvim can cache it
        compile_path = vim.fn.stdpath 'config' .. '/lua/packer_compiled.lua',
    },
}
