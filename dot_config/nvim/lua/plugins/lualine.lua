return {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('lualine').setup {
            sections = {
                lualine_a = { 'mode' },
                lualine_b = {
                    'branch',
                    'diff',
                    { 'diagnostics', symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } },
                },
                lualine_c = { { 'filename', path = 1 } },
                lualine_x = {
                    {
                        require('noice').api.status.mode.get,
                        cond = require('noice').api.status.mode.has,
                        color = { fg = '#ff9e64' },
                    },
                    {
                        require('noice').api.status.search.get,
                        cond = require('noice').api.status.search.has,
                        color = { fg = '#ff9e64' },
                    },
                    'encoding',
                    'fileformat',
                    'filetype',
                },
                lualine_y = { 'progress' },
                lualine_z = { 'location', 'selectioncount' },
            },
        }
    end,
}
