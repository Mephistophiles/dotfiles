return { -- Neovim plugin introducing a new operators motions to quickly replace and exchange text.
    'gbprod/substitute.nvim',
    keys = {
        { 's', CMD "lua require('substitute').operator()", noremap = true },
        { 'ss', CMD "lua require('substitute').line()", noremap = true },
        { 'S', CMD "lua require('substitute').eol()", noremap = true },
        { 's', CMD "lua require('substitute').visual()", mode = 'x', noremap = true },
        { '<leader>s', CMD "lua require('substitute.range').operator()", noremap = true },
        { '<leader>s', CMD "lua require('substitute.range').visual()", mode = 'x', noremap = true },
        { '<leader>ss', CMD "lua require('substitute.range').word()", noremap = true },
        { 'sx', CMD "lua require('substitute.exchange').operator()", noremap = true },
        { 'sxx', CMD "lua require('substitute.exchange').line()", noremap = true },
        { 'X', CMD "lua require('substitute.exchange').visual()", mode = 'x', noremap = true },
        { 'sxc', CMD "lua require('substitute.exchange').cancel()", noremap = true },
    },
    config = function()
        require('substitute').setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    end,
}
