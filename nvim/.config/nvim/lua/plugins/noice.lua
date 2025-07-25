return {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
        -- add any options here
        presets = {
            bottom_search = true,
            inc_rename = true,
        },
    },
    dependencies = {
        'MunifTanjim/nui.nvim',
        'rcarriga/nvim-notify',
    },
}
