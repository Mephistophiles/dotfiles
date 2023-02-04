return { -- VIM Table Mode for instant table creation.
    'dhruvasagar/vim-table-mode',
    keys = {
        { '<leader>tm', CMD 'TableModeToggle', desc = 'TableMode: toggle' },
    },
    cmd = { 'TableModeToggle' },
}
