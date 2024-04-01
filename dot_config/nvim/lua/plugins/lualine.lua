return {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'arkav/lualine-lsp-progress', 'letieu/harpoon-lualine' },
    config = function()
        local function current_lsp()
            local lsp_info = {}

            for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
                table.insert(lsp_info, client.name)
            end

            return table.concat(lsp_info, '|')
        end

        require('lualine').setup {
            sections = {
                lualine_a = { 'mode' },
                lualine_b = {
                    'branch',
                    'diff',
                    { 'diagnostics', symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } },
                },
                lualine_c = {
                    { 'harpoon2', no_harpoon = '' },
                    { 'filename', path = 1 },
                },
                lualine_x = {
                    current_lsp,
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
