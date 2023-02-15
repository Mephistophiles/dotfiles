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

    { -- fugitive.vim: A Git wrapper so awesome, it should be illegal
        'tpope/vim-fugitive',
        cmd = { 'G', 'Git' },
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
}