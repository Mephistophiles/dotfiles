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
        local helpers = require 'ts-node-action.helpers'
        local pairs = {
            rtl_true = 'rtl_false',
            rtl_false = 'rtl_true',
        }

        local function switch(node)
            local node_text = helpers.node_text(node)
            return pairs[node_text] or node_text
        end
        require('ts-node-action').setup {
            c = {
                identifier = {
                    {
                        switch,
                        name = 'Toggle Pairs',
                    },
                },
            },
        }
    end,
}
