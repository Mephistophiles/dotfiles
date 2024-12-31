return {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'letieu/harpoon-lualine' },
    config = function()
        local function current_lsp()
            local lsp_info = {}

            for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
                table.insert(lsp_info, client.name)
            end

            return table.concat(lsp_info, '|')
        end

        local function lint_progress()
            local linters = require('lint').get_running()
            if #linters == 0 then
                return ''
            end
            return '󱉶 ' .. table.concat(linters, ', ')
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
                    lint_progress,
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
