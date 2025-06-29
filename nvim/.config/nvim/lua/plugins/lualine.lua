local function lint_progress()
    local lint = package.loaded.lint

    if lint then
        local linters = lint.get_running()
        if #linters == 0 then
            return ''
        end
        return '󱉶 ' .. table.concat(linters, ', ')
    end

    return ''
end

local function filename()
    return vim.fn.expand '%:~:.'
end

local function breadcrumb()
    local lspsaga = package.loaded.lspsaga

    if lspsaga then
        return require('lspsaga.symbol.winbar').get_bar() or filename()
    end

    return filename()
end

return {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        sections = {
            lualine_a = { 'mode' },
            lualine_b = {
                'branch',
                'diff',
                { 'diagnostics', symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } },
            },
            lualine_c = {
                breadcrumb,
            },
            lualine_x = {
                'searchcount',
                'selectioncount',
                'lsp_status',
                lint_progress,
                'filetype',
            },
            lualine_y = { 'progress' },
            lualine_z = { 'location' },
        },
    },
}
