vim.o.cmdheight = 0
vim.o.laststatus = 3

return {
    'sontungexpt/witch-line',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    lazy = false, -- Almost component is lazy load by default. So you can set lazy to false
    opts = {},
}
