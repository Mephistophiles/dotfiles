return {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    version = 'v3.*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = {
        options = {
            diagnostics = 'nvim_lsp',
        },
    },
}
