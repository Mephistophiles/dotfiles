return {
    'stevearc/oil.nvim',
    keys = {
        {
            '-',
            function()
                require('oil').open_float()
            end,
            mode = { 'n' },
            desc = 'Oil: Open parent directory',
        },
    },
    config = {
        view_options = {
            show_hidden = true,
        },
        keymaps = {
            ['g?'] = 'actions.show_help',
            ['<CR>'] = 'actions.select',
            ['<C-v>'] = 'actions.select_vsplit',
            ['<C-s>'] = 'actions.select_split',
            ['<C-t>'] = 'actions.select_tab',
            ['<leader>p'] = 'actions.preview',
            ['<C-c>'] = 'actions.close',
            ['<C-l>'] = 'actions.refresh',
            ['-'] = 'actions.parent',
            ['_'] = 'actions.open_cwd',
            ['`'] = 'actions.cd',
            ['~'] = 'actions.tcd',
            ['g.'] = 'actions.toggle_hidden',
        },
        use_default_keymaps = false,
    },
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
}
