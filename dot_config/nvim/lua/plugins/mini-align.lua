return {
    'echasnovski/mini.nvim',
    keys = {
        {
            'ga',
            function()
                require('mini.align').make_action_normal(vim.api.nvim_get_mode()['mode'] == 'v')
            end,
            mode = { 'n', 'v' },
            desc = 'Align: Align text',
        },
        {
            'gA',
            function()
                require('mini.align').make_action_visual(vim.api.nvim_get_mode()['mode'] == 'v')
            end,
            mode = { 'n', 'v' },
            desc = 'Align: Align text with preview',
        },
    },
    version = false,
    config = function()
        require('mini.align').setup()
    end
}
