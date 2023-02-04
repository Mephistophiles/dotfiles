return { -- Find the enemy and replace them with dark power.
    'windwp/nvim-spectre',
    keys = {
        {
            '<leader>/',
            CMD 'lua require("plugins.nvim-spectre.utils").open()',
            desc = 'Spectre: Open search panel',
        },
        {
            '<leader>*',
            CMD 'lua require("plugins.nvim-spectre.utils").open_visual { select_word = true }',
            desc = 'Spectre: Search word under cursor',
        },
    },
    config = function()
        require('spectre').setup {
            mapping = {
                ['open_in_vsplit'] = {
                    map = '<c-v>',
                    cmd = CMD 'lua require("plugins.nvim-spectre.utils").vsplit()',
                    desc = 'open in vertical split',
                },
                ['open_in_split'] = {
                    map = '<c-s>',
                    cmd = CMD 'lua require("plugins.nvim-spectre.utils").split()',
                    desc = 'open in horizontal split',
                },
                ['open_in_tab'] = {
                    map = '<c-t>',
                    cmd = CMD 'lua require("plugins.nvim-spectre.utils").tabsplit()',
                    desc = 'open in new tab',
                },
            },
        }
    end,
    dependencies = {
        'kyazdani42/nvim-web-devicons',
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
    },
}
