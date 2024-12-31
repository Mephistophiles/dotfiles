return {
    'MagicDuck/grug-far.nvim',
    cmd = { 'GrugFar' },
    keys = {
        {
            '<leader>/',
            CMD 'GrugFar',
            desc = 'Spectre: Open search panel',
        },
        {
            '<leader>*',
            CMD 'lua require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })',
            desc = 'Spectre: Search word under cursor',
        },
    },
    config = function()
        require('grug-far').setup {
            -- options, see Configuration section below ...
            -- there are no required options atm...
            -- engine = 'ripgrep' is default, but 'astgrep' can be specified...
        }
    end,
}
