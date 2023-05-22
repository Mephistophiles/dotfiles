return { --  Neovim Plugin for running functions on nodes.
    'ckolkey/ts-node-action',
    keys = {
        {
            '<leader><leader>',
            function()
                require('ts-node-action').node_action()
            end,
            desc = 'Trigger Node Action',
        },
    },
    dependencies = { 'nvim-treesitter' },
    config = function() -- Optional
        require('ts-node-action').setup {}
    end,
}
