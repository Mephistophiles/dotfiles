return {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    enabled = false,
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = {
        options = {
            diagnostics = 'nvim_lsp',
        },
    },
}
