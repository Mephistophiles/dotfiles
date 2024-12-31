return { -- magit for neovim
    'TimUntersberger/neogit',
    cmd = { 'Neogit' },
    opts = {
        disable_commit_confirmation = true,
        integrations = {
            diffview = true,
        },
    },
    dependencies = 'nvim-lua/plenary.nvim',
}
