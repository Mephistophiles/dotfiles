return {
    'folke/tokyonight.nvim',
    lazy = true,
    priority = 1000,
    init = function()
        vim.opt.background = 'dark'
        vim.opt.termguicolors = true
    end,
    opts = { style = 'storm' },
}
