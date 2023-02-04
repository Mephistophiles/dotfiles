return { -- A neovim lua plugin to help easily manage multiple terminal windows
    'akinsho/toggleterm.nvim',
    keys = {
        {
            '<F12>',
            CMD 'exe v:count1 . "ToggleTerm"',
            mode = { 'n', 't' },
            silent = true,
            desc = 'Toggleterm: toggle',
        },
    },
    cmd = { 'ToggleTerm' },
    config = function()
        require('toggleterm').setup {}
    end,
}
