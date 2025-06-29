return {
    { -- A clean, dark Neovim theme written in Lua, with support for lsp, treesitter and lots of plugins. Includes additional themes for Kitty, Alacritty, iTerm and Fish.
        'folke/tokyonight.nvim',
        lazy = true,
        priority = 1000,
        init = function()
            vim.opt.background = 'dark'
            vim.opt.termguicolors = true
        end,
        opts = { style = 'storm' },
    },
    { -- enable repeating supported plugin maps with "."
        'tpope/vim-repeat',
    },

    { -- Automatic indentation style detection for Neovim
        'NMAC427/guess-indent.nvim',
        event = { 'BufReadPre' },
        config = function()
            require('guess-indent').setup {}
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
    {
        'lewis6991/fileline.nvim',
        event = { 'BufNewFile' },
        cond = function()
            local file = vim.api.nvim_buf_get_name(0)

            if file == '' then
                return false
            end

            if not file:match '^([^:]+):([0-9:]+)$' then
                return false
            end
            return true
        end,
    },
}
