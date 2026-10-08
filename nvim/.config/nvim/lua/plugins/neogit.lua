return { -- magit for neovim
    'TimUntersberger/neogit',
    cmd = { 'Neogit' },
    opts = {
        console_timeout = 60000,
        auto_show_console = false,
        integrations = {
            diffview = false,
        },
    },
    dependencies = 'nvim-lua/plenary.nvim',
}
