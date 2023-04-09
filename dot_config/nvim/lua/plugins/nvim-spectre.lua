return { -- Find the enemy and replace them with dark power.
    'nvim-pack/nvim-spectre',
    keys = {
        {
            '<leader>/',
            CMD 'lua require"spectre".open()',
            desc = 'Spectre: Open search panel',
        },
        {
            '<leader>*',
            CMD 'lua require"spectre".open_visual({ select_word = true })',
            desc = 'Spectre: Search word under cursor',
        },
    },
    config = function()
        require('spectre').setup {
            mapping = {
                ['open_in_vsplit'] = {
                    map = '<c-v>',
                    cmd = CMD 'lua vim.cmd("vsplit " .. require("spectre.actions").get_current_entry().filename)',
                    desc = 'open in vertical split',
                },
                ['open_in_split'] = {
                    map = '<c-s>',
                    cmd = CMD 'lua vim.cmd("split " .. require("spectre.actions").get_current_entry().filename)',
                    desc = 'open in horizontal split',
                },
                ['open_in_tab'] = {
                    map = '<c-t>',
                    cmd = CMD 'lua vim.cmd("tab split " .. require("spectre.actions").get_current_entry().filename)',
                    desc = 'open in new tab',
                },
            },
        }
    end,
    dependencies = {
        'nvim-tree/nvim-web-devicons',
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
    },
}
