return { -- Add/change/delete surrounding delimiter pairs with ease. Written with heart in Lua.
    'kylechui/nvim-surround',
    event = 'InsertEnter',
    version = '*',
    config = function()
        require('nvim-surround').setup {
            -- Configuration here, or leave empty to use defaults
        }
    end,
}
