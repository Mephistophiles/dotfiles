return { -- Neovim's answer to the mouse
    'ggandor/leap.nvim',
    keys = {
        {
            '<Leader>w',
            '<Plug>(leap-forward-to)',
            desc = 'Leap forward to',
        },
        {
            '<Leader>b',
            '<Plug>(leap-backward-to)',
            desc = 'Leap backward to',
        },
    },
}
