return {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    version = 'v3.*',
    dependencies = 'kyazdani42/nvim-web-devicons',
    config = {
        options = {
            diagnostics = 'nvim_lsp',
        },
    },
}
