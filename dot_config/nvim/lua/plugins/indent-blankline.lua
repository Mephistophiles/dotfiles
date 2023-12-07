return { -- Indent guides for Neovim
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,
    event = 'VeryLazy',
    main = 'ibl',
    opts = {
        scope = {
            show_start = false,
            show_end = false,
        },
    },
}
