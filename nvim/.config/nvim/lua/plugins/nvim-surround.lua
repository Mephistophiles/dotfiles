return { -- Add/change/delete surrounding delimiter pairs with ease. Written with heart in Lua.
    'kylechui/nvim-surround',
    keys = {
        { 'ys', mode = 'n' },
        { 'yss', mode = 'n' },
        { 'yS', mode = 'n' },
        { 'ySS', mode = 'n' },
        { 'ds', mode = 'n' },
        { 'cs', mode = 'n' },
        { 'cS', mode = 'n' },
        { 'S', mode = 'x' },
        { 'gS', mode = 'x' },
        { '<C-g>s', mode = 'i' },
        { '<C-g>S', mode = 'i' },
    },
    version = vim.version.range('*'),
    config = function()
        require('nvim-surround').setup {
            -- Configuration here, or leave empty to use defaults
        }
    end,
}
