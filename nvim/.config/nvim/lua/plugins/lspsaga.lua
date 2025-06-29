return {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
    opts = {
        symbol_in_winbar = {
            enable = false,
        },
        lightbulb = {
            virtual_text = false,
        },
    },
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons', -- optional
    },
}
