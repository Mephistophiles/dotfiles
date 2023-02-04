return {
    { -- A clean, dark Neovim theme written in Lua, with support for lsp, treesitter and lots of plugins. Includes additional themes for Kitty, Alacritty, iTerm and Fish.
        'folke/tokyonight.nvim',
        priority = 1000,
        init = function()
            vim.opt.background = 'dark'
            vim.opt.termguicolors = true
        end,
        config = function()
            require('tokyonight').setup {
                style = 'storm', -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
                -- style = 'moon', -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
            }
            vim.cmd.colorscheme 'tokyonight-storm'
            -- vim.cmd.colorscheme 'tokyonight-moon'
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

    { -- fugitive.vim: A Git wrapper so awesome, it should be illegal
        'tpope/vim-fugitive',
        cmd = { 'G', 'Git' },
    },
    { -- magit for neovim
        'TimUntersberger/neogit',
        cmd = { 'Neogit' },
        config = {
            disable_commit_confirmation = true,
            integrations = {
                diffview = true,
            },
        },
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

    { -- Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more
        'numToStr/Comment.nvim',
        event = { 'VeryLazy', 'InsertCharPre' },
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
        config = function()
            require('symbols-outline').setup()
        end,
    },

    { -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
        'sindrets/diffview.nvim',
        dependencies = 'kyazdani42/nvim-web-devicons',
        cmd = { 'DiffviewOpen' },
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

    { -- Vim syntax for TOML
        'cespare/vim-toml',
        ft = 'toml',
    },

    { -- Interactive real time neovim scratchpad for embedded lua engine - type and watch!
        'rafcamlet/nvim-luapad',
        cmd = { 'Luapad' },
    },

    { -- Vim plugin that defines a new text object representing lines of code at the same indent level. Useful for python/vim scripts, etc.
        'michaeljsmith/vim-indent-object',
    },

    { -- A better annotation generator. Supports multiple languages and annotation conventions.
        'danymat/neogen',
        cmd = 'Neogen',
        config = function()
            require('neogen').setup { enabled = true }
        end,
        dependencies = 'nvim-treesitter/nvim-treesitter',
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
}
