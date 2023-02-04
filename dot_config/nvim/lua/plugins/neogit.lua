return { -- magit for neovim
    'TimUntersberger/neogit',
    cmd = { 'Neogit' },
    config = {
        disable_commit_confirmation = true,
        integrations = {
            diffview = true,
        },
    },
    dependencies = 'nvim-lua/plenary.nvim',
}
