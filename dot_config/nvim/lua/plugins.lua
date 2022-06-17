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
        use { 'hrsh7th/cmp-copilot', requires = { 'github/copilot.vim' } } -- copilot

        use 'wsdjeg/vim-fetch'

        use {
            'hoob3rt/lualine.nvim',
            requires = { 'kyazdani42/nvim-web-devicons', opt = true },
            config = function()
                require('lualine').setup {
                    options = { theme = 'tokyonight' },
                    sections = {
                        lualine_c = {
                            { 'filename', file_status = true, path = 1 },
                        },
                    },
                }
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

        use {
            'echasnovski/mini.nvim', -- original author (blackCauldron7) has been deleted (unsupported repo)
            config = function()
                require('mini.surround').setup {
                    custom_surroundings = {
                        ['b'] = {
                            input = { find = '%b()', extract = '^(.).*(.)$' },
                            output = { left = '(', right = ')' },
                        },
                        ['B'] = {
                            input = { find = '%b{}', extract = '^(.).*(.)$' },
                            output = { left = '{', right = '}' },
                        },
                    },
                    -- Number of lines within which surrounding is searched
                    n_lines = 20,

                    -- How to search for surrounding (first inside current line, then inside
                    -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
                    -- 'cover_or_nearest'. For more details, see `:h MiniSurround.config`.
                    search_method = 'cover',

                    -- Module mappings. Use `''` (empty string) to disable one.
                    mappings = {
                        add = 'ys', -- Add surrounding
                        delete = 'ds', -- Delete surrounding
                        find = '', -- Find surrounding (to the right)
                        find_left = '', -- Find surrounding (to the left)
                        highlight = '', -- Highlight surrounding
                        replace = 'cs', -- Replace surrounding
                        update_n_lines = '', -- Update `n_lines`
                    },
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
            cmd = { 'Telescope' },
            module = 'telescope',
            setup = function()
                require('settings.telescope').setup()
            end,
            config = function()
                require('telescope').setup {
                    defaults = {
                        mappings = {
                            i = {
                                ['<C-Down>'] = require('telescope.actions').cycle_history_next,
                                ['<C-Up>'] = require('telescope.actions').cycle_history_prev,
                            },
                        },
                    },
                }

                require('telescope').load_extension 'ui-select'
                require('telescope').load_extension 'project'
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
            'Darazaki/indent-o-matic',
            config = function()
                require('indent-o-matic').setup {
                    -- The values indicated here are the defaults

                    -- Number of lines without indentation before giving up (use -1 for infinite)
                    max_lines = 2048,

                    -- Space indentations that should be detected
                    standard_widths = { 2, 4, 8 },
                }
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
            'AndrewRadev/switch.vim',
            cmd = 'Switch',
            keys = { '-' },
            setup = function()
                vim.g.switch_mapping = '-'
                vim.g.switch_find_smallest_match = 0
                vim.g.switch_custom_definitions = {
                    { 'd_str_t', 'd_str_auto_t' },
                    { 'json_t', 'json_auto_t' },
                    { 'd_jrpcmsg_t', 'd_jrpcmsg_auto_t' },
                    { 'd_dynarray_t', 'd_dynarray_auto_t' },
                    { 'd_vect_t', 'd_vect_auto_t' },
                    { 'json_object_set_nocheck', 'json_object_set_new_nocheck' },
                    { 'json_object_set', 'json_object_set_new' },
                    { 'json_array_append', 'json_array_append_new' },
                    {
                        ['^\\(\\k\\+\\)=y'] = '# \\1 is not set',
                        ['^# \\(\\k\\+\\) is not set'] = '\\1=y',
                    },
                }
            end,
        }

        use {
            'aserowy/tmux.nvim',
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
        use { 'tommcdo/vim-exchange', opt = true, keys = { 'cx' } }

        use {
            'rhysd/conflict-marker.vim',
            opt = true,
            cond = function()
                return vim.opt.diff:get()
            end,
            setup = function()
                -- matchit is not installed
                vim.g.conflict_marker_enable_matchit = 0
            end,
        }

        use { 'cespare/vim-toml', ft = 'toml' }

        use {
            'ggandor/leap.nvim',
            opt = true,
            keys = { { 'n', '<leader>w' }, { 'n', '<leader>b' } },
            config = function()
                vim.keymap.set(
                    'n',
                    '<leader>w',
                    '<Plug>(leap-forward)',
                    { silent = true, desc = 'EasyMotion forward motion' }
                )
                vim.keymap.set(
                    'n',
                    '<leader>b',
                    '<Plug>(leap-backward)',
                    { silent = true, desc = 'EasyMotion backward motion' }
                )
                require('leap').setup {
                    case_insensitive = true,
                    -- Leaving the appropriate list empty effectively disables "smart" mode,
                    -- and forces auto-jump to be on or off.
                    -- safe_labels = { . . . },
                    -- labels = { . . . },
                    -- These keys are captured directly by the plugin at runtime.
                    special_keys = {
                        repeat_search = '<enter>',
                        next_match = '<enter>',
                        prev_match = '<tab>',
                        next_group = '<space>',
                        prev_group = '<tab>',
                        eol = '<space>',
                    },
                }
            end,
        }

        use {
            'rlane/pounce.nvim',
            disable = false,
            opt = true,
            module = 'pounce',
            setup = function()
                vim.keymap.set('n', '<leader>s', function()
                    require('pounce').pounce {}
                end, { desc = 'Pounce fuzzy search in page' })
                vim.keymap.set('n', '<leader>S', function()
                    require('pounce').pounce { do_repeat = true }
                end, { desc = 'Pounce: repeat last search' })
            end,
            config = function()
                require('pounce').setup {
                    accept_keys = 'JFKDLSAHGNUVRBYTMICEOXWPQZ',
                    accept_best_key = '<enter>',
                    multi_window = true,
                    debug = false,
                }
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
                        if level and level > vim.log.levels.INFO then
                            msg = msg .. '\n' .. debug.traceback()
                        end

                        notify_fn(msg, level, opts)
                    end,
                    __index = function(_, key)
                        return notify_fn[key]
                    end,
                })
            end,
        }

        use { 'wakatime/vim-wakatime' }

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
            'voldikss/vim-floaterm',
            config = function()
                vim.g.floaterm_shell = 'fish'
                vim.g.floaterm_width = 0.7
                vim.g.floaterm_height = 0.7
            end,
            setup = function()
                vim.keymap.set('n', '<F12>', [[:FloatermToggle<CR>]], { silent = true, desc = 'Floaterm: toggle' })
                vim.keymap.set(
                    't',
                    '<F12>',
                    [[<C-\><C-n>:FloatermToggle<CR>]],
                    { silent = true, desc = 'Floaterm: toggle' }
                )
            end,
            cmd = { 'FloatermNew', 'FloatermToggle' },
        }

        use {
            'anuvyklack/pretty-fold.nvim',
            config = function()
                require('pretty-fold').setup {}
                require('pretty-fold.preview').setup {}
            end,
            requires = { 'anuvyklack/nvim-keymap-amend' },
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
                    -- your configuration comes here
                    -- or leave it empty to use the default settings
                    -- refer to the configuration section below
                }
            end,
        }

        use {
            'rhysd/git-messenger.vim',
            cmd = { 'GitMessenger' },
            keys = { '<leader>gm' },
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
            requires = { 'rcarriga/nvim-dap-ui', 'theHamsta/nvim-dap-virtual-text' },
            module = 'dap',
            lazy = true,
            setup = function()
                require('settings.dap').setup()
            end,
            config = function()
                require('settings.dap').config()
            end,
        }

        use 'rhysd/committia.vim'

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
            'norcalli/nvim-colorizer.lua',
            config = function()
                require('colorizer').setup()
            end,
        }

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
            'koenverburg/peepsight.nvim',
            cmd = { 'PeepsightEnable', 'PeepsightDisable' },
            config = function()
                require('peepsight').setup {
                    -- go
                    'function_declaration',
                    'method_declaration',
                    'func_literal',

                    -- typescript
                    'arrow_function',
                    'function_declaration',
                    'generator_function_declaration',
                }
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
            config = function()
                require('textcase').setup {}
            end,
        }

        use {
            'Vonr/align.nvim',
            keys = {
                { 'x', '<leader>aa' },
                { 'x', '<leader>as' },
                { 'x', 'aw' },
                { 'x', 'ar' },
                { 'n', 'gaw' },
                { 'n', 'gaa' },
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
                -- 'rcarriga/neotest-vim-test',
                'nvim-treesitter/nvim-treesitter',
            },
            setup = function()
                vim.api.nvim_create_user_command('Neotest', function()
                    require('neotest').run.run()
                end, { desc = 'Neotest: run nearest test' })
                vim.api.nvim_create_user_command('NeotestFile', function()
                    require('neotest').run.run(vim.fn.expand '%')
                end, { desc = 'Neotest: run the current file' })
                vim.api.nvim_create_user_command('NeotestStop', function()
                    require('neotest').run.stop()
                end, { desc = 'Neotest: stop the nearest test' })

                vim.keymap.set('n', '<leader>tf', function()
                    require('neotest').run.run(vim.fn.expand '%')
                end, { desc = 'Neotest: run all tests in file' })

                vim.keymap.set('n', '<leader>tn', function()
                    require('neotest').run.run()
                end, { desc = 'Neotest: run nearest test' })

                vim.keymap.set('n', '<leader>tl', function()
                    require('neotest').run.run_last()
                end, { desc = 'Neotest: run last test' })
                vim.keymap.set('n', '<leader>ts', function()
                    require('neotest').summary.toggle()
                end, { desc = 'Neotest: toggle summary' })
                vim.keymap.set('n', '<leader>to', function()
                    require('neotest').output.open { enter = true }
                end, { desc = 'Neotest: show test output' })
            end,
            config = function()
                require('neotest').setup {
                    adapters = {
                        require 'neotest-plenary',
                        -- require 'neotest-vim-test' {
                        --     ignore_file_types = { 'vim', 'lua' },
                        -- },
                    },
                }
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
    end,
    config = {
        -- Move to lua dir so impatient.nvim can cache it
        compile_path = vim.fn.stdpath 'config' .. '/lua/packer_compiled.lua',
    },
}
