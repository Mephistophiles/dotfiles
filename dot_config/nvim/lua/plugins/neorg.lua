return {
    'nvim-neorg/neorg',
    dependencies = { { 'vhyrro/luarocks.nvim', priority = 1000, config = true }, 'nvim-treesitter' },
    ft = 'norg',
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = '*', -- Pin Neorg to the latest stable release
    config = function()
        require('neorg').setup {
            load = {
                ['core.defaults'] = {},
                ['core.concealer'] = {},
                ['core.completion'] = { config = { engine = 'nvim-cmp' } },
                ['core.integrations.nvim-cmp'] = {},
                ['core.keybinds'] = {
                    config = {
                        default_keybinds = true,
                    },
                },
            },
        }
    end,
}
