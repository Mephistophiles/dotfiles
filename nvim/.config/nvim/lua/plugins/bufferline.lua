return {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    opts = {
        options = {
            auto_toggle_bufferline = true,
            always_show_bufferline = false,
            diagnostics = 'nvim_lsp',
        },
    },
    dependencies = 'nvim-tree/nvim-web-devicons',
}
