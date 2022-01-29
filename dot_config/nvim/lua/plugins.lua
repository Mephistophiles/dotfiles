-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

local packer = require('packer')
local use = packer.use

return packer.startup({
    function()
        -- Packer can manage itself
        use 'wbthomason/packer.nvim'
        -- Speedup loading
        use 'lewis6991/impatient.nvim'

        -- neovim mappings (wait for neovim 0.7)
        use 'b0o/mapx.nvim'

        -- filedetect drop-in-placement
        use {'nathom/filetype.nvim', setup = function() vim.g.did_load_filetypes = 1 end}

        -- extended repeat ('.') for another plugins
        use 'tpope/vim-repeat'

        use {
            'neovim/nvim-lspconfig',
            requires = {
                {
                    'ray-x/lsp_signature.nvim',
                    config = function()
                        require'lsp_signature'.setup({toggle_key = '<C-S>'})
                    end,
                }, 'lspcontainers/lspcontainers.nvim',
            },
        }

        use 'hrsh7th/cmp-nvim-lsp' -- language server protocol
        use 'hrsh7th/cmp-buffer' -- completion from current buffer
        use 'onsails/lspkind-nvim' -- print completion source in menu
        use 'L3MON4D3/LuaSnip' -- snippet engine
        use 'hrsh7th/cmp-path' -- completion for filesystem
        use {'tzachar/cmp-tabnine', run = './install.sh'} -- tabnine
        use 'hrsh7th/nvim-cmp'

        use 'wsdjeg/vim-fetch'

        use {'airblade/vim-rooter', config = function() vim.g.rooter_patterns = {'.git'} end}

        use {
            'hoob3rt/lualine.nvim',
            requires = {'kyazdani42/nvim-web-devicons', opt = true},
            config = function()
                require('lualine').setup({
                    options = {theme = 'tokyonight'},
                    sections = {
                        lualine_c = {
                            {'filename', file_status = true, path = 1},
                            [[require'lsp-status'.status()]],
                        },
                    },
                })
            end,
        }
        use {
            'folke/tokyonight.nvim',
            config = function()
                vim.opt.background = 'dark'
                vim.opt.termguicolors = true
                vim.cmd('colorscheme tokyonight')
            end,
        }
        use {
            'kyazdani42/nvim-tree.lua',
            module = 'nvim-tree',
            requires = {'kyazdani42/nvim-web-devicons', opt = true},
            setup = function()
                MAP.nnoremap([[<C-\>]], function()
                    require('nvim-tree').find_file(true)
                end)
                MAP.nnoremap([[<leader><leader>]], function()
                    require('nvim-tree').toggle()
                end)
            end,
            config = function() require'nvim-tree'.setup {} end,
        }
        use {'tpope/vim-fugitive', cmd = {'G', 'Git'}, opt = true}

        use {
            'blackCauldron7/surround.nvim',
            config = function()
                require'surround'.setup {map_insert_mode = false, mappings_style = 'surround'}

                vim.api.nvim_del_keymap('v', 's') -- remove surrond visual
            end,
        }

        use {
            'lewis6991/gitsigns.nvim',
            requires = {'nvim-lua/plenary.nvim'},
            config = function()
                require('gitsigns').setup({
                    current_line_blame = true,

                    on_attach = function(bufnr)
                        local gs = package.loaded.gitsigns

                        local function map(mode, l, r, opts)
                            opts = opts or {}
                            opts.buffer = bufnr

                            if type(mode) == 'string' then mode = {mode} end

                            for _, m in ipairs(mode) do
                                local func_name = m .. 'map'
                                MAP[func_name](l, r, opts)
                            end
                        end

                        -- Navigation
                        map('n', ']c', [[&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>']],
                            {expr = true})
                        map('n', '[c', [[&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>']],
                            {expr = true})

                        -- Actions
                        map({'n', 'v'}, '<leader>hs', gs.stage_hunk)
                        map({'n', 'v'}, '<leader>hr', gs.reset_hunk)
                        map('n', '<leader>hS', gs.stage_buffer)
                        map('n', '<leader>hu', gs.undo_stage_hunk)
                        map('n', '<leader>hR', gs.reset_buffer)
                        map('n', '<leader>hp', gs.preview_hunk)
                        map('n', '<leader>hb', function()
                            gs.blame_line {full = true}
                        end)
                        map('n', '<leader>tb', gs.toggle_current_line_blame)
                        map('n', '<leader>hd', gs.diffthis)
                        map('n', '<leader>hD', function() gs.diffthis('~') end)
                        map('n', '<leader>td', gs.toggle_deleted)

                        -- Text object
                        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                    end,

                })
            end,
        }

        use {
            'nvim-telescope/telescope.nvim',
            requires = {
                {'nvim-lua/popup.nvim', module = 'popup'}, 'nvim-lua/plenary.nvim',
                'nvim-telescope/telescope-ui-select.nvim', 'nvim-telescope/telescope-project.nvim',
            },
            cmd = {'Telescope'},
            module = 'telescope',
            setup = function() require('settings.telescope').setup() end,
            config = function()
                require('telescope').load_extension('ui-select')
                require('telescope').load_extension('project')
            end,
        }

        use {
            'windwp/nvim-spectre',
            opt = true,
            module = 'spectre',
            setup = function()
                MAP.nnoremap('<leader>S', function() require('spectre').open() end)
                MAP.nnoremap('<leader>sw',
                             function()
                    require('spectre').open_visual({select_word = true})
                end)
            end,
            config = function()
                require('spectre').setup({
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
                })
            end,
            requires = {
                'kyazdani42/nvim-web-devicons', {'nvim-lua/popup.nvim', module = 'popup'},
                'nvim-lua/plenary.nvim',
            },
        }

        use {'numToStr/Comment.nvim', config = function() require('Comment').setup() end}

        use {
            'mg979/vim-visual-multi',
            keys = {'<c-n>'},
            config = function()
                vim.g.VM_reselect_first = 1
                vim.g.VM_case_setting = 'sensitive'
            end,
        }

        use {
            'simrat39/symbols-outline.nvim',
            cmd = {'SymbolsOutline'},
            setup = function() MAP.nmap('<F5>', '<cmd>SymbolsOutline<cr>') end,
        }

        use {
            'mhartington/formatter.nvim',
            cmd = {'Format', 'FormatWrite'},
            event = {'BufWritePre'},
            config = function() require('settings.formatter').setup() end,
        }

        use {
            'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate',
            requires = {'p00f/nvim-ts-rainbow'},
        }

        use {
            'Darazaki/indent-o-matic',
            config = function()
                require('indent-o-matic').setup {
                    -- The values indicated here are the defaults

                    -- Number of lines without indentation before giving up (use -1 for infinite)
                    max_lines = 2048,

                    -- Space indentations that should be detected
                    standard_widths = {2, 4, 8},
                }
            end,
        }

        use {
            'godlygeek/tabular',
            cmd = {'Tabularize'},
            opt = true,
            setup = function()
                MAP.nnoremap('<leader>a', ':Tabularize /')
                MAP.vnoremap('<leader>a', ':Tabularize /')
            end,
        }

        use {
            'sindrets/diffview.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
            cmd = {'DiffviewOpen'},
            opt = true,
        }

        use {
            'mbbill/undotree',
            cmd = 'UndotreeToggle',
            setup = function() MAP.noremap('<F3>', '<cmd>UndotreeToggle<CR>') end,
            opt = true,
        }

        use {
            'AndrewRadev/switch.vim',
            cmd = 'Switch',
            keys = {'-'},
            setup = function()
                vim.g.switch_mapping = '-'
                vim.g.switch_find_smallest_match = 0
                vim.g.switch_custom_definitions = {
                    {'d_str_t', 'd_str_auto_t'}, {'json_t', 'json_auto_t'},
                    {'d_jrpcmsg_t', 'd_jrpcmsg_auto_t'}, {'d_dynarray_t', 'd_dynarray_auto_t'},
                    {'d_vect_t', 'd_vect_auto_t'},
                    {'json_object_set_nocheck', 'json_object_set_new_nocheck'},
                    {'json_object_set', 'json_object_set_new'},
                    {'json_array_append', 'json_array_append_new'},
                    {
                        ['^\\(\\k\\+\\)=y'] = '# \\1 is not set',
                        ['^# \\(\\k\\+\\) is not set'] = '\\1=y',
                    },
                }

            end,
        }

        use {
            'christoomey/vim-tmux-navigator',
            opt = true,
            cmd = {
                'TmuxNavigateLeft', 'TmuxNavigateDown', 'TmuxNavigateUp', 'TmuxNavigateRight',
                'TmuxNavigatePrevious',
            },
            setup = function()
                vim.g.tmux_navigator_no_mappings = 1

                MAP.nnoremap('<c-h>', '<cmd>TmuxNavigateLeft<cr>')
                MAP.nnoremap('<c-l>', '<cmd>TmuxNavigateRight<cr>')
                MAP.nnoremap('<a-h>', '<cmd>TmuxNavigateLeft<cr>')
                MAP.nnoremap('<a-j>', '<cmd>TmuxNavigateDown<cr>')
                MAP.nnoremap('<a-k>', '<cmd>TmuxNavigateUp<cr>')
                MAP.nnoremap('<a-l>', '<cmd>TmuxNavigateRight<cr>')
                MAP.nnoremap('<BS>', '<cmd>TmuxNavigatePrevious<cr>')
            end,
        }

        use {
            'chrisbra/vim-kconfig',
            ft = 'kconfig',
            setup = function()
                vim.cmd('au BufRead,BufNewFile Config.in setlocal filetype=kconfig')
            end,
        }

        use {
            'mfussenegger/nvim-ts-hint-textobject',
            setup = function()
                MAP.omap('m', function() require('tsht').nodes() end)
                MAP.vnoremap('m', function() require('tsht').nodes() end)
            end,
            opt = true,
            module = 'tsht',
        }
        use {
            'tpope/vim-eunuch',
            opt = true,
            cmd = {
                'Delete', 'Unlink', 'Move', 'Rename', 'Chmod', 'Mkdir', 'Cfind', 'Clocate',
                'Lfind/', 'Wall', 'SudoWrite', 'SudoEdit',
            },
        }

        use {'LnL7/vim-nix', opt = true, ft = 'nix'}
        use {'tommcdo/vim-exchange', opt = true, keys = {'cx'}}

        use {
            'rhysd/conflict-marker.vim',
            opt = true,
            cond = function() return vim.opt.diff:get() end,
            setup = function()
                -- matchit is not installed
                vim.g.conflict_marker_enable_matchit = 0
            end,
        }

        use {'cespare/vim-toml', ft = 'toml'}

        use {
            'phaazon/hop.nvim',
            disable = true,
            as = 'hop',
            cmd = {
                'HopWord', 'HopWordAC', 'HopWordBC', 'HopPattern', 'HopChar1', 'HopChar2',
                'HopLine',
            },
            setup = function()
                MAP.map('<Leader>w', '<CMD>HopWordAC<CR>')
                MAP.map('<Leader>b', '<CMD>HopWordBC<CR>')
                MAP.map('<Leader>l', '<CMD>HopLine<CR>')
                MAP.map('<Leader>f', '<CMD>HopChar1AB<CR>')
                MAP.map('<Leader>F', '<CMD>HopChar1BC<CR>')
                -- MAP.map('<Leader>s', '<CMD>HopChar2<CR>')
                -- MAP.map('<Leader>p', '<CMD>HopPattern<CR>')
            end,
            config = function()
                -- you can configure Hop the way you like here; see :h hop-config
                require'hop'.setup {keys = 'etovxqpdygfblzhckisuran'}
            end,
        }

        use {
            'ggandor/lightspeed.nvim',
            disable = false,
            config = function()
                MAP.map('<leader>w', '<Plug>Lightspeed_s')
                MAP.map('<leader>b', '<Plug>Lightspeed_S')
                MAP.map('<leader>f', '<Plug>Lightspeed_f')
                MAP.map('<leader>F', '<Plug>Lightspeed_F')
                MAP.map('<leader>t', '<Plug>Lightspeed_t')
                MAP.map('<leader>T', '<Plug>Lightspeed_T')
            end,
        }

        use {'rafcamlet/nvim-luapad', cmd = {'Luapad'}}

        use {'xiyaowong/nvim-cursorword'}

        use {
            'ThePrimeagen/harpoon',
            requires = {'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim'},
            module = 'harpoon',
            setup = function()
                MAP.map('<Leader>`', function()
                    require('harpoon.ui').toggle_quick_menu()
                end)
                MAP.map('<Leader>h', function() require('harpoon.mark').add_file() end)
                MAP.map('<Leader>1', function() require('harpoon.ui').nav_file(1) end)
                MAP.map('<Leader>2', function() require('harpoon.ui').nav_file(2) end)
                MAP.map('<Leader>3', function() require('harpoon.ui').nav_file(3) end)
                MAP.map('<Leader>4', function() require('harpoon.ui').nav_file(4) end)
                MAP.map('<Leader>5', function() require('harpoon.ui').nav_file(5) end)
                MAP.map('<Leader>6', function() require('harpoon.ui').nav_file(6) end)
            end,
        }

        use {'teal-language/vim-teal', ft = 'teal'}
        use {'andymass/vim-matchup'}
        use {'rcarriga/nvim-notify', config = function() vim.notify = require('notify') end}

        use {'wakatime/vim-wakatime'}

        use {'michaeljsmith/vim-indent-object'}

        use 'simrat39/rust-tools.nvim'
        use {
            'saecki/crates.nvim',
            ft = 'rust',
            event = {'BufRead Cargo.toml'},
            requires = {{'nvim-lua/plenary.nvim'}},
            config = function() require('crates').setup() end,
        }

        use {
            'danymat/neogen',
            cmd = 'Neogen',
            config = function() require('neogen').setup {enabled = true} end,
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
                MAP.nnoremap('<F12>', [[:FloatermToggle<CR>]], 'silent')
                MAP.tnoremap('<F12>', [[<C-\><C-n>:FloatermToggle<CR>]], 'silent')
            end,
            cmd = {'FloatermNew', 'FloatermToggle'},
        }

        use {
            'anuvyklack/pretty-fold.nvim',
            config = function()
                require('pretty-fold').setup({})
                require('pretty-fold.preview').setup()
            end,
        }

        use 'stevearc/dressing.nvim'

        use {
            'folke/trouble.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
            cmd = {'Trouble', 'TroubleToggle'},
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
            cmd = {'GitMessenger'},
            keys = {'<leader>gm'},
            setup = function() MAP.nnoremap('<leader>gm', '<Plug>(git-messenger)') end,
        }

        use {
            'j-hui/fidget.nvim',
            config = function()
                require('fidget').setup {text = {spinner = 'dots'}, align = {bottom = true}}
            end,
        }
    end,
    config = {
        -- Move to lua dir so impatient.nvim can cache it
        compile_path = vim.fn.stdpath('config') .. '/lua/packer_compiled.lua',
    },
})
