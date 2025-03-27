return {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
    opts = {
        lightbulb = {
            virtual_text = false,
        },
    },
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons', -- optional
    },
}
