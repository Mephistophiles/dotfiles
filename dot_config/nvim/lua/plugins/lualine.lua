return {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'arkav/lualine-lsp-progress' },
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
                    'overseer',
                    'lsp_progress',
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
