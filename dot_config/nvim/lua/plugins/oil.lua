return {
    'stevearc/oil.nvim',
    config = function()
        require('oil').setup {
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
        }
        vim.keymap.set('n', '-', require('oil').open_float, { desc = 'Open parent directory' })
    end,
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
}
